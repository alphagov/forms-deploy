terraform {
    required_version = "~>1.5"

    required_providers {
        aws = "~>5.19"
        
        auth0 = {
            source  = "auth0/auth0"
            version = "~> 1.0.0"
        }
    }
}