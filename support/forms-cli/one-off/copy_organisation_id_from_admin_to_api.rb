# frozen_string_literal: true

require_relative "./helpers"

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

run
