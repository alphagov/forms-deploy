require "English"
require "shellwords"

describe "container images" do
  all_terraform_functions = `terraform metadata functions -json | jq -r '.function_signatures|keys|.[]'`
      .split("\n")
      .map! { |s| "#{s}(" }

  discovered_images = `git grep -Eoh "image\s+=.*" | awk '{print $3}' | tr -d '"'`
      .split("\n")
      .reject! { |s| s.start_with? "var." }
      .reject! { |s| s.start_with? "local." }
      .reject! { |s| s.start_with? "$INPUT_IMAGE_URI" }
      .reject! { |s| all_terraform_functions.any? { |func| s.start_with? func } }
      .map!(&:strip)
      .map! { |s| s.split(":")[0] }
      .uniq

  discovered_images.each do |image|
    describe image do
      it "uses the same version everywhere" do
        instances = `git grep --no-color -Eoh '#{Shellwords.escape(image)}:[A-Za-z\.0-9$\{\}_]+' | uniq`

        expect($CHILD_STATUS).to eq 0

        num_instances = instances.split("\n").length
        expect(num_instances).to eq(1), "Found #{num_instances} tags in use for image '#{image}'. There should be only one. \n #{instances}"
      end
    end
  end
end
