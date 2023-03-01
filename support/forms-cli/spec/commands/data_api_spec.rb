# frozen_string_literal: true

require 'commands/data_api'
require_relative '../fixtures/secretsmanager'
require_relative '../fixtures/rds'
require_relative '../fixtures/rdsdataservice'

describe DataApi do
  context 'when not authenticated' do
    it 'prompts the user to authenticate' do
      expect { DataApi.new.run }.to output(/You must be authenticated/).to_stdout
    end
  end

  context 'when authenticated' do
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
      stub_const('ARGV', ['-d', 'forms-api', '-s', 'select * from testing;'])

      allow_any_instance_of(Helpers)
        .to receive(:aws_authenticated?)
        .and_return(true)

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

    it 'set correct rds cluster arn' do
      DataApi.new.run

      expect(data_api_mock)
        .to have_received(:execute_statement)
        .with(hash_including(resource_arn: 'cluster-arn'))
        .at_least(:once)
    end

    it '-d, --database is correctly passed to secrets manager' do
      DataApi.new.run

      expect(secrets_manager_mock)
        .to have_received(:list_secrets)
        .with(hash_including(filters: [{ key: 'all', values: ['forms-api-app'] }]))
        .at_least(:once)
    end

    it '-d, --database is correctly passed to data api' do
      DataApi.new.run

      expect(data_api_mock)
        .to have_received(:execute_statement)
        .with(hash_including(database: 'forms-api'))
        .at_least(:once)
    end

    it '-s, --statement is correctly passed' do
      DataApi.new.run

      expect(data_api_mock)
        .to have_received(:execute_statement)
        .with(hash_including(sql: 'select * from testing;'))
        .at_least(:once)
    end
  end
end
