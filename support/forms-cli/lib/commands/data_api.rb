# frozen_string_literal: true

require 'aws-sdk-secretsmanager'
require 'aws-sdk-rds'
require 'aws-sdk-rdsdataservice'
require 'colorize'
require_relative '../utilities/helpers'

# Executes statements on AWS RDS using the Data API.
class DataApi
  include Helpers

  def run
    @options = {}
    parse_options
    return unless aws_authenticated? && valid_options?

    @secrets_manager = Aws::SecretsManager::Client.new
    @rds = Aws::RDS::Client.new
    @data_service = Aws::RDSDataService::Client.new

    begin
      print execute_statement
    rescue RuntimeError => e
      puts "Something went wrong: #{e.message}".red
    end
  end

  private

  def print(results)
    puts JSON.pretty_generate({
                                updated: results.number_of_records_updated,
                                records: JSON.parse(execute_statement.formatted_records)
                              })
  end

  def valid_options?
    %i[statement database].each do |arg|
      if @options[arg].nil?
        puts "#{arg} must be provided".red
        return false
      end
    end

    unless %w[forms-api forms-admin].include? @options[:database]
      puts "database must be either 'forms-api' or 'forms-admin'".red
      return false
    end

    true
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "
      Executes the provided statement on the provide database for the currently
      authenticated shell.

      Run in a authorized shell using gds-cli or aws-vault.

      Example:
      gds aws gds-forms-dev-support -- forms data_api --database forms-api --statement 'select * from forms;'\n\n"

      opts.on('-h', '--help', 'Prints help') do
        puts opts
        exit
      end

      opts.on('-dDATABASE', '--database=DATABASE', '[Mandatory] database to query, forms-api forms-admin') do |database|
        @options[:database] = database
      end

      opts.on('-sSTATEMENT', '--statement=STATEMENT', '[Mandatory] The statement to execute') do |statement|
        @options[:statement] = statement
      end
    end.parse!
  end

  def query_credential_arn
    credential_name = "#{@options[:database]}-app"
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

  def execute_statement
    params = {
      resource_arn: query_database_cluster_arn,
      secret_arn: query_credential_arn,
      sql: @options[:statement],
      database: @options[:database],
      include_result_metadata: true,
      format_records_as: 'JSON' # Its simpler to get the results as JSON and parse it back...
    }
    @data_service.execute_statement(params)
  end
end
