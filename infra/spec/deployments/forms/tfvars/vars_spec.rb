# frozen_string_literal: true

require "open3"
require "json"

def hcl2json(file)
  stdout, stderr, exit_status = Open3.capture3("hcl2json", file)

  warn stderr unless exit_status.success?
  JSON.parse(stdout)
end

vars_files = Dir.glob(repo_path("infra/deployments/forms/tfvars/*.tfvars")).map { |f|
  file_name = File.basename(f)
  json = hcl2json(f)

  [file_name, json]
}.to_h

describe "terraform vars" do
  context "in environment" do
    vars_files.each do |file_name, json|
      describe(file_name) do
        it "root domain is a subdomin of 'forms.service.gov.uk'" do
          expect(json["root_domain"]).to end_with "forms.service.gov.uk"
        end

        applications = %w[forms_admin_settings
                          forms_api_settings
                          forms_product_page_settings
                          forms_runner_settings]
        applications.each do |app|
          describe app do
            it "must have max_capacity set" do
              max_capacity = json[app]["max_capacity"]
              expect(max_capacity).not_to be_nil
            end

            it "must have max_capacity set" do
              max_capacity = json[app]["max_capacity"]
              expect(max_capacity).not_to be_nil
            end

            it "must have min_capacity set" do
              min_capacity = json[app]["min_capacity"]
              expect(min_capacity).not_to be_nil
            end

            it "must have max_capacity >= min_capacity" do
              max_capacity = json[app]["max_capacity"]
              min_capacity = json[app]["min_capacity"]
              expect(max_capacity).to be >= min_capacity
            end

            it "must check maximum instances is divisible by 3" do
              max_capacity = json[app]["max_capacity"]
              expect(max_capacity % 3).to be == 0
            end

            it "must check minimum instances is divisible by 3" do
              min_capacity = json[app]["min_capacity"]
              expect(min_capacity % 3).to be == 0
            end

            it "must check max_capacity and min_capacity are whole numbers" do
              max_capacity = json[app]["max_capacity"]
              min_capacity = json[app]["min_capacity"]
              expect(max_capacity % 1).to be == 0
              expect(min_capacity % 1).to be == 0
            end

            it "must check max_capacity and min_capacity are whole numbers" do
              max_capacity = json[app]["max_capacity"]
              min_capacity = json[app]["min_capacity"]
              expect(max_capacity % 1).to be == 0
              expect(min_capacity % 1).to be == 0
            end

            it "must have CPU set to specified values" do
              cpu = json[app]["cpu"]
              expect([256, 512, 1024, 2048, 4096, 8192, 16_384]).to include(cpu)
            end

            it "must check cpu and memory are compatible" do
              cpu = json[app]["cpu"]
              memory = json[app]["memory"]
              case cpu
              when 256
                expect([512, 1024, 2048]).to include(memory)
              when 512
                expect([1024, 2048, 4096, 8192, 16_384]).to include(memory)
              when 1024
                expect([2048, 3072, 4096, 5120, 6144, 7168, 8192]).to include(memory)
              when 2048
                expect((4..16).map { |n| n * 1024 }).to include(memory)
              when 4096
                expect((8..30).map { |n| n * 1024 }).to include(memory)
              when 8192
                expect((16..60).step(4).map { |n| n * 1024 }).to include(memory)
              when 16_384
                expect((32..120).step(8).map { |n| n * 1024 }).to include(memory)
              end
            end
          end
        end
      end
    end
  end

  describe "across all environments" do
    it "the Auth0 splunk stream is enabled only once" do
      enabled_statuses = vars_files.map { |_, json| json["environmental_settings"]["enable_auth0_splunk_log_stream"] }
      number_enabled = enabled_statuses.count { |enabled| enabled }

      expect(number_enabled).to be <= 1, "while we do not have an Auth0 enterprise agreement, we can have a maximum of 1 log stream enabled across all of our environments"
    end
  end
end
# rubocop:enable Metrics/BlockLength
