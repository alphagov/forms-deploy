# frozen_string_literal: true

require "commands/data_api"
require "utilities/data_api_connection"

require_relative "../fixtures/rdsdataservice"

describe DataApi do
  context "when not authenticated" do
    it "prompts the user to authenticate" do
      expect { DataApi.new.run }.to output(/You must be authenticated/).to_stdout
    end
  end

  context "when authenticated" do
    let(:data_api_connection_mock) do
      data_api_connection_mock = instance_double(DataApiConnection)
      allow(data_api_connection_mock)
        .to receive(:execute_statement)
        .and_return(RDSDataServiceFixtures.execute_statement)

      data_api_connection_mock
    end

    before do
      stub_const("ARGV", ["-d", "forms-api", "-s", "select * from testing;"])

      allow_any_instance_of(Helpers)
        .to receive(:aws_authenticated?)
        .and_return(true)

      allow(DataApiConnection)
        .to receive(:new)
        .and_return(data_api_connection_mock)
    end

    it "-d, --database is correctly passed to DataApiConnection" do
      DataApi.new.run

      expect(DataApiConnection)
        .to have_received(:new)
        .with("forms-api")
        .at_least(:once)
    end

    it "-s, --statement is correctly passed to DataApiConnection" do
      DataApi.new.run

      expect(data_api_connection_mock)
        .to have_received(:execute_statement)
        .with("select * from testing;")
        .at_least(:once)
    end
  end
end
