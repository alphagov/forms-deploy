# All accounts

This is a [data-only module](https://developer.hashicorp.com/terraform/language/modules/develop/composition#data-only-modules),
like the `users` module. It makes exposes information about every GOV.UK Forms
AWS Account, so that it can be used wherever one account needs to know about
another without needing to hardcode the information.
