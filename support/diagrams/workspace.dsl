workspace "GOV.UK Forms" "An MVP architecture." {

    !identifiers hierarchical

    model {
        forms = softwareSystem "GOV.UK Forms" {

            # Containers: represent a deployable unit that contributes to the functionality of the system (e.g., web app, db)
            # Can also represent nested or related infrastructure components
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

            sessionsDB = container "Forms Sessions Database" {
                technology "Redis"
                description "20 hours expiry"
                tags "Database"
            }

            cloudWatchLogs = container "CloudWatch Logs" {
                technology "CloudWatch"
                description "Application and system logs"
                tags "Amazon Web Services - CloudWatch"
            }

            cloudWatchAlarms = container "CloudWatch Alarm" {
                technology "CloudWatch"
                tags "Amazon Web Services - CloudWatch Alarm"
            }

            cloudWatchMetrics = container "CloudWatch Metrics" {
                technology "CloudWatch"
                tags "Amazon Web Services - CloudWatch"
            }

            # Relationships
            formsAdmin -> usersDB "Reads from and writes to" "PostgreSQL Protocol/SSL"
            formsAPI -> formsDefinitionsDB "Reads from and writes to" "PostgreSQL Protocol/SSL"
            formsRunner -> sessionsDB "Reads from and writes to" "Redis"
            formsRunner -> cloudWatchMetrics "Writes metrics to"
            formsAdmin -> cloudWatchMetrics "Reads metrics from"
        }

        # Deployment Environment represents the context in which containers, deployment nodes, and infrastructure nodes are deployed
        environment = deploymentEnvironment "Environment" {
            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud"

                # Deployment Nodes represents infrastructure components where containers and/or services are deployed
                # or a collection of interrelated infrastructure components
                region = deploymentNode "eu-west-2" {
                    tags "Amazon Web Services - Region"

                    # Infrastructure Nodes represent individual or isolated infrastructure components
                    dns = infrastructureNode "DNS router" {
                        technology "Route 53"
                        description "Routes incoming requests based upon domain name"
                        tags "Amazon Web Services - Route 53"
                    }

                    alb = infrastructureNode "Load Balancer" {
                        technology "ALB"
                        description "Automatically distributes incoming application traffic"
                        tags "Amazon Web Services - Elastic Load Balancing ELB Application load balancer"
                    }

                    shieldAdvanced = infrastructureNode "Shield Advanced" {
                        technology "Shield Advanced"
                        description "DDoS Protection service"
                        tags "Amazon Web Services - Shield Shield Advanced"
                    }

                    wafRules = infrastructureNode "WAF Rules" {
                        technology "WAF"
                        tags "Amazon Web Services - WAF"
                    }

                    cloudFront = infrastructureNode "CloudFront" {
                        technology "CloudFront"
                        description "Routes incoming requests to Application Load Balancer"
                        tags "Amazon Web Services - CloudFront"
                    }

                    cloudTrail = infrastructureNode "CloudTrail" {
                        technology "CloudTrail"
                        description "Logs AWS activity - forwards logs to Cyber"
                        tags "Amazon Web Services - CloudTrail"
                    }

                    parameterStore = infrastructureNode "SSM ParameterStore" {
                        technology "ParameterStore"
                        description "Stores secrets and credentials"
                        tags "Amazon Web Services - Systems Manager Parameter Store"
                    }

                    # Deployment Nodes represents infrastructure components where containers and/or services are deployed
                    # or a collection of interrelated infrastructure components
                    deploymentNode "ECS Fargate - GOV.UK Forms cluster" {
                        tags "Amazon Web Services - Fargate"
                        # Define container instances
                        formsAdmin = containerInstance forms.formsAdmin
                        formsAPI = containerInstance forms.formsAPI
                        formsProductPage = containerInstance forms.formsProductPage
                        formsRunner = containerInstance forms.formsRunner

                        # Create connections from the ALB to all container instances
                        alb -> formsAdmin "Forwards requests to" "HTTPS"
                        alb -> formsAPI "Forwards requests to" "HTTPS"
                        alb -> formsProductPage "Forwards requests to" "HTTPS"
                        alb -> formsRunner "Forwards requests to" "HTTPS"
                    }

                    deploymentNode "RDS" {
                        tags "Amazon Web Services - RDS"

                        deploymentNode "Users DB" {
                            tags "Amazon Web Services - RDS Postgres instance"
                            usersDB = containerInstance forms.usersDB
                        }

                        deploymentNode "Forms Definitions DB" {
                            tags "Amazon Web Services - RDS Postgres instance"
                            formsDefinitionsDB = containerInstance forms.formsDefinitionsDB
                        }
                    }

                    deploymentNode "Elasticache" {
                        tags "Amazon Web Services - ElastiCache"
                        sessionsDB = containerInstance forms.sessionsDB
                    }

                    deploymentNode "CloudWatch" {
                        tags "Amazon Web Services - CloudWatch"
                        description "CloudWatch Services: logging, metrics, and alerts"

                        logs = containerInstance forms.cloudWatchLogs
                        alarms = containerInstance forms.cloudWatchAlarms
                        metrics = containerInstance forms.cloudWatchMetrics
                    }

                    # Relationships
                    cloudFront -> alb "Forwards requests to" "HTTPS"
                    dns -> cloudFront "Forwards requests to" "HTTPS"
                    shieldAdvanced -> cloudFront "Monitors traffic for DDoS"
                    wafRules -> cloudFront "Enforces WAF rules on traffic to"
                }
            }
        }
    }

    views {
        deployment forms environment "AmazonWebServicesDeployment" {
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