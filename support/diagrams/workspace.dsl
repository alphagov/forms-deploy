workspace "GOV.UK Forms" "An MVP architecture." {

    !identifiers hierarchical

    model {
        forms = softwaresystem "GOV.UK Forms" {
            forms_admin = container "forms-admin" {
                technology "Ruby on Rails"
                tags "Application"
            }

            forms_api = container "forms-api" {
                technology "Ruby on Rails"
                tags "Application"
            }

            forms_product_page = container "forms-product-page" {
                technology "Ruby on Rails"
                tags "Application"
            }

            forms_runner = container "forms-runner" {
                technology "Ruby on Rails"
                tags "Application"
            }

            users_db = container "Users Database" {
                technology "Postgres"
                tags "Database"
            }

            forms_definitions_db = container "Forms Definition Database" {
                technology "Postgres"
                tags "Database"
            }

            forms_admin -> users_db "Reads from and writes to" "PostgreSQL Protocol/SSL"
            forms_api -> forms_definitions_db "Reads from and writes to" "PostgreSQL Protocol/SSL"
        }

        live = deploymentEnvironment "Live" {
            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud"

                region = deploymentNode "eu-west-2" {
                    tags "Amazon Web Services - Region"

                    dns = infrastructureNode "DNS router" {
                        technology "Route 53"
                        description "Routes incoming requests based upon domain name."
                        tags "Amazon Web Services - Route 53"
                    }

                    cloudfront = infrastructureNode "Cloudfront distribution" {
                        technology "CloudFront"
                        description "Routes incoming requests to Application Load Balancer."
                        tags "Amazon Web Services - CloudFront"
                        dns -> this "Forwards requests to" "HTTPS"
                    }

                    alb = infrastructureNode "Load Balancer" {
                        technology "ALB"
                        description "Automatically distributes incoming application traffic."
                        tags "Amazon Web Services - Elastic Load Balancing ELB Application load balancer"
                        cloudfront -> this "Forwards requests to" "HTTPS"
                    }

                    deploymentNode "ECS Fargate - GOV.UK Forms cluster" {
                        tags "Amazon Web Services - Fargate"
                        // Define container instances
                        forms_admin = containerInstance forms.forms_admin
                        forms_api = containerInstance forms.forms_api
                        forms_product_page = containerInstance forms.forms_product_page
                        forms_runner = containerInstance forms.forms_runner

                        // Create a single connection from the ALB to all container instances
                        alb -> forms_admin "Forwards requests to" "HTTPS"
                        alb -> forms_api "Forwards requests to" "HTTPS"
                        alb -> forms_product_page "Forwards requests to" "HTTPS"
                        alb -> forms_runner "Forwards requests to" "HTTPS"
                    }

                    deploymentNode "Amazon RDS" {
                        tags "Amazon Web Services - RDS"

                        deploymentNode "Users DB" {
                            tags "Amazon Web Services - RDS Postgres instance"

                            databaseInstance1 = containerInstance forms.users_db
                        }

                        deploymentNode "Forms Definitions DB" {
                            tags "Amazon Web Services - RDS Postgres instance"

                            databaseInstance2 = containerInstance forms.forms_definitions_db
                        }
                    }

                }
            }
        }
    }

    views {
        deployment forms live "AmazonWebServicesDeployment" {
            include *
            autolayout tb
        }

        styles {
            element "Element" {
                shape roundedbox
                background #ffffff
            }
            element "Container" {
                background #ffffff
            }
            element "Application" {
                background #ffffff
            }
            element "Database" {
                shape cylinder
            }
        }

        themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
    }

}