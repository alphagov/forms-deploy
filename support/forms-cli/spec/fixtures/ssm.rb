# frozen_string_literal: true

require "time"

# Fixtures for SSM api calls
module SsmFixtures
  @ssm_client_stub = Aws::SSM::Client.new({ stub_responses: true })

  def self.get_parameters_by_path
    @ssm_client_stub.stub_data(:get_parameters_by_path, { parameters: [{ name: "/some/parameters/path/one",
                                                                         type: "SecureString",
                                                                         value: "dummy_value",
                                                                         version: 1,
                                                                         last_modified_date: Time.parse("2023-01-01"),
                                                                         arn: "some-arn",
                                                                         data_type: "text" },
                                                                       { name: "/some/parameters/path/two",
                                                                         type: "SecureString",
                                                                         value: "dummy_value",
                                                                         version: 2,
                                                                         last_modified_date: Time.parse("2023-01-01"),
                                                                         arn: "some-arn",
                                                                         data_type: "text" }],
                                                          next_token: nil })
  end
end
