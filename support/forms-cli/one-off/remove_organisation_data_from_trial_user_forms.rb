# frozen_string_literal: true

require_relative "./helpers"

def run
  trial_user_ids = admin_db
  .execute_statement("SELECT id FROM users WHERE role='trial';")[:records]
  .map { |row| row[:id].to_i }

  where_clause = "WHERE creator_id IN #{format_sql_array_string(trial_user_ids)} AND organisation_id IS NOT NULL"
  result = if ENV["DRY_RUN"]
             api_db.execute_statement <<~SQL
               SELECT * from forms
               #{where_clause}
             SQL
           else
             api_db.execute_statement <<~SQL
               UPDATE forms
               SET organisation_id = NULL
               #{where_clause}
             SQL
           end

  puts result if ENV["DRY_RUN"]
  puts "UPDATE #{result[:number_of_records_updated]}"
end

run
