# frozen_string_literal: true

require 'aws-sdk-secretsmanager'
require 'aws-sdk-rds'
require 'aws-sdk-rdsdataservice'

# Executes statements on AWS RDS using the Data API.
class DataApiConnection
  def initialize(database_name)
    @database_name = database_name

    @data_service = Aws::RDSDataService::Client.new
    @rds = Aws::RDS::Client.new
    @secrets_manager = Aws::SecretsManager::Client.new
  end

  def execute_statement(statement)
    params = {
      resource_arn: query_database_cluster_arn,
      secret_arn: query_credential_arn,
      sql: statement,
      database: @database_name,
      include_result_metadata: true,
      format_records_as: 'JSON' # Its simpler to get the results as JSON and parse it back...
    }
    @data_service.execute_statement(params)
  end

  private

  def query_credential_arn
    credential_name = "#{@database_name}-app"
    params = {
      filters: [
        { key: 'all', values: [credential_name] }
      ]
    }
    arn = @secrets_manager.list_secrets(params)&.secret_list&.[](0)&.arn

    raise "Credential named #{credential_name} was not found" if arn.nil?

    arn
  end

  def query_database_cluster_arn
    arn = @rds.describe_db_clusters&.db_clusters&.[](0)&.db_cluster_arn

    raise 'Database cluster was not be found' if arn.nil?

    arn
  end
end
