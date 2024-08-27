require "yaml"
require "json-schema"

describe "running-order.yml" do
  schema = File.read("#{__dir__}/running_order_schema.json")
  running_order = YAML.load_file("#{__dir__}/../../deployments/running-order.yml")

  it "is valid" do
    expect(JSON::Validator.validate!(schema, running_order)).to be true
  end

  it "does not contain any unknown roots" do
    deployments_dir = File.expand_path("#{__dir__}/../../deployments")

    forms_roots = Dir.glob("#{deployments_dir}/forms/*")
                     .select { |f| File.directory?(f) }
                     .map { |f| f.delete_prefix("#{deployments_dir}/") }
                     .reject { |f| f == "forms/tfvars" }

    deploy_roots = Dir.glob("#{deployments_dir}/deploy/*")
                      .select { |f| File.directory?(f) }
                      .map { |f| f.delete_prefix("#{deployments_dir}/") }

    valid_roots =
      %w[account] + forms_roots + deploy_roots

    used_roots =
      running_order["running-order"]["layers"].map { |layer|
        layer["phases"].map do |phase|
          phase["roots"]
        end
      }.flatten

    used_roots.each do |root|
      expect(valid_roots).to(include(root), "#{root} is not a known Terraform root")
    end
  end
end
