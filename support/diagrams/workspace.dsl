workspace "GOV.UK Forms" "An MVP architecture." {

    !identifiers hierarchical

    model {
        forms = softwareSystem "GOV.UK Forms" {
            formsAdmin = container "forms-admin" {
                technology "Ruby on Rails"
                tags "Application"
            }

            formsAPI = container "forms-api" {
                technology "Ruby on Rails"
                tags "Application"
            }

            formsProductPage = container "forms-product-page" {
                technology "Ruby on Rails"
                tags "Application"
            }

            formsRunner = container "forms-runner" {
                technology "Ruby on Rails"
                tags "Application"
            }

            usersDB = container "Users Database" {
                technology "Postgres"
                tags "Database"
            }

            formsDefinitionsDB = container "Forms Definition Database" {
                technology "Postgres"
                tags "Database"
            }

            formsAdmin -> usersDB "Reads from and writes to" "PostgreSQL Protocol/SSL"
            formsAPI -> formsDefinitionsDB "Reads from and writes to" "PostgreSQL Protocol/SSL"
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
                        formsAdmin = containerInstance forms.formsAdmin
                        formsAPI = containerInstance forms.formsAPI
                        formsProductPage = containerInstance forms.formsProductPage
                        formsRunner = containerInstance forms.formsRunner

                        // Create a single connection from the ALB to all container instances
                        alb -> formsAdmin "Forwards requests to" "HTTPS"
                        alb -> formsAPI "Forwards requests to" "HTTPS"
                        alb -> formsProductPage "Forwards requests to" "HTTPS"
                        alb -> formsRunner "Forwards requests to" "HTTPS"
                    }

                    deploymentNode "Amazon RDS" {
                        tags "Amazon Web Services - RDS"

                        deploymentNode "Users DB" {
                            tags "Amazon Web Services - RDS Postgres instance"

                            databaseInstance1 = containerInstance forms.usersDB
                        }

                        deploymentNode "Forms Definitions DB" {
                            tags "Amazon Web Services - RDS Postgres instance"

                            databaseInstance2 = containerInstance forms.formsDefinitionsDB
                        }
                    }

                }
            }
        }
    }

    views {
        deployment forms live "AmazonWebServicesDeployment" {
            include *
            autolayout lr
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