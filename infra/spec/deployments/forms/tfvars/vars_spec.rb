require "open3"
require "json"

def hcl2json(file)
    stdout, stderr, exit_status = Open3.capture3("hcl2json", file)

    unless exit_status.success?
        warn stderr
    end
    JSON.parse(stdout)
end

describe "terraform vars" do
    Dir.glob(repo_path("infra/deployments/forms/tfvars/*.tfvars")).each do |f|
        file_name = File.basename(f)
        
        describe(file_name) do
            subject(:json) {
                hcl2json(f)
            } 
        
            it "root domain is a subdomin of 'forms.service.gov.uk'" do
                expect(json["root_domain"]).to end_with "forms.service.gov.uk"
            end
        end
        
    end
end