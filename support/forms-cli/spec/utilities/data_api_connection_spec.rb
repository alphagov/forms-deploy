# frozen_string_literal: true

require "utilities/data_api_connection"

require_relative "../fixtures/secretsmanager"
require_relative "../fixtures/rds"
require_relative "../fixtures/rdsdataservice"

describe DataApiConnection do
  let(:secrets_manager_mock) do
    secrets_manager_mock = instance_double(Aws::SecretsManager::Client)
    allow(secrets_manager_mock)
      .to receive(:list_secrets)
      .and_return(SecretsManagerFixtures.list_secrets)

    secrets_manager_mock
  end

  let(:rds_mock) do
    rds_mock = instance_double(Aws::RDS::Client)
    allow(rds_mock)
      .to receive(:describe_db_clusters)
      .and_return(RDSFixtures.describe_db_clusters)

    rds_mock
  end

  let(:data_api_mock) do
    data_api_mock = instance_double(Aws::RDSDataService::Client)
    allow(data_api_mock)
      .to receive(:execute_statement)
      .and_return(RDSDataServiceFixtures.execute_statement)

    data_api_mock
  end

  before do
    allow(Aws::SecretsManager::Client)
      .to receive(:new)
      .and_return(secrets_manager_mock)

    allow(Aws::RDS::Client)
      .to receive(:new)
      .and_return(rds_mock)

    allow(Aws::RDSDataService::Client)
      .to receive(:new)
      .and_return(data_api_mock)
  end

  it "set correct rds cluster arn" do
    described_class.new("forms-api").execute_statement("select * from testing;")

    expect(data_api_mock)
      .to have_received(:execute_statement)
      .with(hash_including(resource_arn: "cluster-arn"))
      .at_least(:once)
  end

  it "database_name is correctly passed to secrets manager" do
    described_class.new("forms-api").execute_statement("select * from testing;")

    expect(secrets_manager_mock)
      .to have_received(:list_secrets)
      .with(hash_including(filters: [{ key: "all", values: %w[forms-api-app] }]))
      .at_least(:once)
  end

  it "database_name is correctly passed to data api" do
    described_class.new("forms-api").execute_statement("select * from testing;")

    expect(data_api_mock)
      .to have_received(:execute_statement)
      .with(hash_including(database: "forms-api"))
      .at_least(:once)
  end

  it "statement is correctly passed" do
    described_class.new("forms-api").execute_statement("select * from testing;")

    expect(data_api_mock)
      .to have_received(:execute_statement)
      .with(hash_including(sql: "select * from testing;"))
      .at_least(:once)
  end
end
