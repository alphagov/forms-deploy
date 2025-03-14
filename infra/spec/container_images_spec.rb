require "English"
require "shellwords"

describe "container images" do
  discovered_images = `git grep -Eoh "image\s+=.*" | awk '{print $3}' | tr -d '"' | grep -I ":"`
      .split("\n")
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
