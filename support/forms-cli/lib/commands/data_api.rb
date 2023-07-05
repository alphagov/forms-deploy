# frozen_string_literal: true

require "colorize"
require_relative "../utilities/data_api_connection"
require_relative "../utilities/helpers"

# Executes statements on AWS RDS using the Data API.
class DataApi
  include Helpers

  def run
    @options = {}
    parse_options
    return unless aws_authenticated? && valid_options?

    @connection = DataApiConnection.new(@options[:database])

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
      records: results.records,
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
    OptionParser.new { |opts|
      opts.banner = "
      Executes the provided statement on the provide database for the currently
      authenticated shell.

      Run in a authorized shell using gds-cli or aws-vault.

      Example:
      gds aws gds-forms-dev-support -- forms data_api --database forms-api --statement 'select * from forms;'\n\n"

      opts.on("-h", "--help", "Prints help") do
        puts opts
        exit
      end

      opts.on("-dDATABASE", "--database=DATABASE", "[Mandatory] database to query, forms-api forms-admin") do |database|
        @options[:database] = database
      end

      opts.on("-sSTATEMENT", "--statement=STATEMENT", "[Mandatory] The statement to execute") do |statement|
        @options[:statement] = statement
      end
    }.parse!
  end

  def execute_statement
    @connection.execute_statement(@options[:statement])
  end
end
