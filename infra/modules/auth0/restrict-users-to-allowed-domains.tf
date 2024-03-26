resource "auth0_action" "restrict_users_to_allowed_domains" {
  name = "restrict-users-to-allowed-domains"

  runtime = "node18"
  code    = <<-EOT
    /**
    * Handler that will be called during the execution of a PreUserRegistration flow.
    *
    * @param {Event} event - Details about the context and user that is attempting to register.
    * @param {PreUserRegistrationAPI} api - Interface whose methods can be used to change the behavior of the signup.
    */
    let domains = ${jsonencode(var.allowed_email_domains)}
    exports.onExecutePreUserRegistration = async (event, api) => {
      if (event.user.email && !domains.some((domain) => event.user.email.endsWith(domain))) {
        api.access.deny("unauthorised_email_domain", "Error: use your government email address.");
      }
    };
  EOT

  supported_triggers {
    id      = "pre-user-registration"
    version = "v2"
  }

  deploy = true
}

resource "auth0_trigger_actions" "pre_user_registration_flow" {
  trigger = "pre-user-registration"

  actions {
    id           = auth0_action.restrict_users_to_allowed_domains.id
    display_name = auth0_action.restrict_users_to_allowed_domains.name
  }
}

moved {
  from = auth0_action.restrict_users_to_govuk_domains
  to   = auth0_action.restrict_users_to_allowed_domains
}
