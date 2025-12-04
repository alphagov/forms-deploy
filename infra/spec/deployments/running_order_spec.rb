require "yaml"
require "json-schema"

describe "running-order.yml" do
  let(:schema) { File.read("#{__dir__}/running_order_schema.json") }
  let(:running_order) { YAML.load_file("#{__dir__}/../../deployments/running-order.yml") }
  let(:deployments_dir) { File.expand_path("#{__dir__}/../../deployments") }

  let(:deployment_types) { %w[forms deploy integration] }

  let(:all_roots) do
    deployment_types.flat_map do |deployment_type|
      Dir.glob("#{deployments_dir}/#{deployment_type}/*")
         .select { |f| File.directory?(f) }
         .map { |f| f.delete_prefix("#{deployments_dir}/") }
         .reject { |f| f.end_with?("/tfvars") }
    end
  end

  let(:used_roots) do
    roots = []
    running_order["running-order"].each_value do |deployment_config|
      deployment_config["layers"].each do |layer|
        layer["phases"].each do |phase|
          roots.concat(phase["roots"])
        end
      end
    end
    roots
  end

  it "is valid" do
    expect(JSON::Validator.validate!(schema, running_order)).to be true
  end

  it "does not contain any unknown roots" do
    used_roots.each do |root|
      expect(all_roots).to(include(root), "#{root} is not a known Terraform root")
    end
  end

  it "contains all known roots" do
    all_roots.each do |root|
      expect(used_roots).to(include(root), "#{root} exists but is not in running-order.yml")
    end
  end
end
