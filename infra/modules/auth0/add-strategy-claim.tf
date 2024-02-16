resource "auth0_action" "add_strategy_claim" {
  name = "add-strategy-claim"

  runtime = "node18"
  code    = <<-EOT
    /**
    * Handler that will be called during the execution of a PostLogin flow.
    *
    * @param {Event} event - Details about the user and the context in which they are logging in.
    * @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
    */
    exports.onExecutePostLogin = async (event, api) => {
        // This action adds the authenticated user's strategy to the ID token.

        if (event.authorization) {
            api.idToken.setCustomClaim('auth0_connection_strategy', event.connection.strategy);
        }
    };
  EOT

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }

  deploy = true
}

resource "auth0_trigger_actions" "post_login_flow" {
  trigger = "post-login"

  actions {
    id           = auth0_action.add_strategy_claim.id
    display_name = auth0_action.add_strategy_claim.name
  }
}
