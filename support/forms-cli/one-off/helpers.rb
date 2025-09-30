# frozen_string_literal: true

require_relative "../lib/utilities/data_api_connection"

def admin_db
  @admin_db ||= if ENV["FORMS_ENV"] == "local"
                  PG.connect(ENV["DATABASE_URL"], dbname: "forms_admin_development")
                else
                  DataApiConnection.new("forms-admin")
                end
end

def api_db
  @api_db ||= if ENV["FORMS_ENV"] == "local"
                PG.connect(ENV["DATABASE_URL"], dbname: "forms_api_development")
              else
                raise "forms-api database connection no longer available"
              end
end

def format_sql_literal(obj)
  if obj.is_a? String
    "'#{obj}'"
  else
    obj.inspect
  end
end

def format_sql_array_string(array)
  "(#{array.map { |element| format_sql_literal(element) }.join(', ')})"
end

def format_sql_values_string(values)
  "VALUES #{values.map { |row| format_sql_array_string(row) }.join(', ')}"
end

# local mode for testing/debugging
if ENV["FORMS_ENV"] == "local"
  require "pg"

  class PG::Connection
    def execute_statement(sql)
      puts "***********"
      puts sql

      result = exec(sql)

      puts [result.inspect, result.to_a.inspect]

      OpenStruct.new({
        number_of_records_updated: result.cmd_status.start_with?("UPDATE") ? result.cmd_tuples : 0,
        records: result.map { |row| OpenStruct.new(row) },
      })
    end
  end
end
