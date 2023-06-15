# frozen_string_literal: true

require "commands/forms_api_tokens"
require "json"

describe FormsApiTokens do
  context "when using the -s, --service option" do
    describe "shell is not authenticated" do
      it "prompts the user to authenticate" do
        stub_const("ARGV", ["--token", "some-valid-token", "--service", "forms-admin"])
        expect { described_class.new.run }.to output(/You must be authenticated/).to_stdout
      end
    end

    describe "shell is authenticated" do
      let(:ssm_mock) do
        ssm = instance_double(Aws::SSM::Client)
        allow(ssm)
          .to receive(:put_parameter)
          .and_return(true)

        ssm
      end

      let(:ecs_mock) do
        ecs_mock = instance_double(Aws::ECS::Client)
        allow(ecs_mock)
          .to receive(:update_service)
          .and_return(true)

        ecs_mock
      end

      let(:sts_stub) do
        sts_stub = instance_double(Aws::STS::Client)
        allow(sts_stub)
          .to receive(:get_caller_identity)
          .and_return(OpenStruct.new(account: "498160065950"))

        sts_stub
      end

      let(:valid_token) do
        "some-valid-token"
      end

      let(:forms_api_stub) do
        expected_uri = URI("https://api.dev.forms.service.gov.uk/api/v1/access-tokens")
        expected_headers = { "Authorization" => "Token #{valid_token}" }
        expected_params = "owner=forms-admin&description=Used by the forms-admin app"
        allow(Net::HTTP)
          .to receive(:post)
          .with(expected_uri, expected_params, expected_headers)
          .and_return(OpenStruct.new({
            code: "201",
            body: { token: "new-test-token" }.to_json,
          }))
      end

      before do
        forms_api_stub
        stub_const("ARGV", ["--token", valid_token, "--service", "forms-admin"])
        allow_any_instance_of(Helpers) # rubocop:todo RSpec/AnyInstance
          .to receive(:aws_authenticated?)
          .and_return(true)
        allow(Aws::STS::Client)
          .to receive(:new)
          .and_return(sts_stub)
        allow(Aws::SSM::Client)
          .to receive(:new)
          .and_return(ssm_mock)
        allow(Aws::ECS::Client)
          .to receive(:new)
          .and_return(ecs_mock)
      end

      it "only allows forms-admin and forms-runner" do
        stub_const("ARGV", ["--token", valid_token, "--service", "not-allowed"])

        expect { described_class.new.run }.to output(/service must be "forms-admin" or "forms-runner"/).to_stdout
      end

      it "updates parameter store" do
        described_class.new.run

        expect(ssm_mock)
          .to have_received(:put_parameter)
          .with({
            name: "/forms-admin-dev/forms-api-key",
            value: "new-test-token",
            type: "SecureString",
            overwrite: true,
          })
      end

      it "redeploys the service" do
        described_class.new.run

        expect(ecs_mock)
          .to have_received(:update_service)
          .with({
            service: "forms-admin",
            cluster: "forms-dev",
            force_new_deployment: true,
          })
      end
    end
  end
end
