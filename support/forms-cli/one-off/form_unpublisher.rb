require_relative "./helpers"

##
# This script will remove a form from the made_live_forms table
# which will unpublish the form and put it back into "draft" state.
#
# @param form_id [Integer] the id of the form to unpublish
#
# Usage with the forms-cli and running against development as an example:
# 1. In forms-deploy/support/forms-cli
# 2. run:
# ```gds aws gds-forms-dev-support -- DRY_RUN=true && ruby remove_organisation_data_from_trial_user_forms.rb```
#
class FormUnpublisher
  def run(form_id)
    where_clause = "WHERE form_id = '#{form_id}'"

    result = if ENV["DRY_RUN"]
               api_db.execute_statement <<~SQL
                 SELECT * FROM made_live_forms #{where_clause}
               SQL
             else
               api_db.execute_statement <<~SQL
                 DELETE FROM made_live_forms #{where_clause}
               SQL
             end
  end
end

form_id = ARGV[0] if ARGV[0] && ARGV[0].to_i.positive?
raise "Please provide a valid form id" unless form_id

FormUnpublisher.new.run(form_id)
