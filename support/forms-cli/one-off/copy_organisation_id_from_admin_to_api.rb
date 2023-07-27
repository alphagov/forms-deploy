# frozen_string_literal: true

require_relative "../lib/utilities/data_api_connection"

class CopyOrganisationIdFromAdminToApi
  def run
    organisation_slugs = api_db
      .execute_statement("SELECT DISTINCT org FROM forms;")[:records]
      .map { |row| row[:org] }
      .compact

    organisation_ids_slugs = admin_db
      .execute_statement("SELECT id, slug FROM organisations WHERE slug IN #{format_sql_array_string(organisation_slugs)};")[:records]
      .map { |row| [row[:id].to_i, row[:slug]] }

    result = api_db.execute_statement <<~SQL
      UPDATE forms SET organisation_id = organisations.id
        FROM (#{format_sql_values_string(organisation_ids_slugs)}) AS organisations (id, slug)
        WHERE forms.org = organisations.slug;
    SQL

    puts "UPDATE #{result[:number_of_records_updated]}"

    orphans = api_db.execute_statement("SELECT id FROM forms WHERE organisation_id IS null AND org IS NOT null;")
    unless orphans.records.empty?
      puts "WARNING: Could not assign correct organisation_id to #{orphans.records.length} forms"
    end
  end

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
                  DataApiConnection.new("forms-api")
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

CopyOrganisationIdFromAdminToApi.new.run
