# frozen_string_literal: true

require "time"

# Fixtures for secrets manager api calls
module RDSDataServiceFixtures
  @rds_dataservice_stub = Aws::RDSDataService::Client.new({ stub_responses: true })

  def self.execute_statement
    @rds_dataservice_stub.stub_data(:execute_statement,
                                    { records: [],
                                      column_metadata: [],
                                      number_of_records_updated: 0,
                                      generated_fields: [],
                                      formatted_records: '[{"id": 1, "name": "some-form"}]' })
  end
end
