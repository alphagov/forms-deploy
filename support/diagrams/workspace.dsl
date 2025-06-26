workspace "GOV.UK Forms" "An MVP architecture." {

    !identifiers hierarchical

    model {
        forms = softwareSystem "GOV.UK Forms" {

            # Containers: represent a deployable unit that contributes to the functionality of the system (e.g., web app, db)
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

            usersDB = container "users-db" {
                technology "Postgres"
                tags "Database"
            }

            formsDefinitionsDB = container "forms-definitions-db" {
                technology "Postgres"
                tags "Database"
            }

            sessionsDB = container "forms-sessions-db" {
                technology "Redis"
                description "20 hours expiry"
                tags "Database"
            }

            solidQueue = container "file-upload-solidqueue" {
                technology "Postgres"
                tags "Database"
            }

            auditTrail = container "forms-runner-audit-trail" {
                technology "Postgres"
                tags "Database"
            }

            pipelineVisualiser = container "pipeline-visualiser" {
                technology "Sinatra"
                tags "Application"
            }

            # Relationships
            # <source> -> <destination> "Description" "Protocol/technology"
            formsAdmin -> usersDB "Reads from and writes to" "PostgreSQL Protocol/SSL"
            formsAPI -> formsDefinitionsDB "Reads from and writes to" "PostgreSQL Protocol/SSL"
            formsRunner -> sessionsDB "Reads from and writes to" "Redis"
            formsRunner -> solidQueue "Writes to"
        }

        # Deployment Environment represents the context in which containers, deployment nodes, and infrastructure nodes are deployed
        formsEnvironments = deploymentEnvironment "Forms Environments" {
            allEnvironments = deploymentNode "All Environments" {
                tags "Amazon Web Services - Cloud"

                # Deployment Nodes represents infrastructure components where containers and/or services are deployed
                # or a collection of interrelated infrastructure components
                region = deploymentNode "eu-west-2" {
                    tags "Amazon Web Services - Region"

                    # Infrastructure Nodes represent individual or isolated infrastructure components
                    # These can be consolidated into a Deployment Node or as standalone components
                    infrastructureNode "CloudTrail" {
                        technology "CloudTrail"
                        description "Logs AWS activity - forwards logs to Cyber"
                        tags "Amazon Web Services - CloudTrail"
                    }

                    infrastructureNode "CodeBuild" {
                        technology "CodeBuild"
                        tags "Amazon Web Services - CodeBuild"
                    }

                    infrastructureNode "SSM ParameterStore" {
                        technology "ParameterStore"
                        description "Stores secrets and credentials"
                        tags "Amazon Web Services - Systems Manager Parameter Store"
                    }

                    InfrastructureNode "SES One Time Password" {
                        technology "SES"
                        description "Sends OTP emails for admin onboarding"
                        tags "Amazon Web Services - Simple Email Service SES"
                    }

                    simpleNotificationService = infrastructureNode "Forms Runner SNS" {
                        technology "SNS"
                        tags "Amazon Web Services - Simple Notification Service SNS"
                    }

                    codePipeline = infrastructureNode "CodePipeline" {
                        technology "CodePipeline"
                        tags "Amazon Web Services - CodePipeline"
                    }

                    eventBridge = infrastructureNode "EventBridge" {
                        technology "EventBridge"
                        tags "Amazon Web Services - EventBridge"
                    }

                    fileUploadS3 = infrastructureNode "File Upload S3" {
                        technology "S3"
                        description "Stores Forms Runner file uploads"
                        tags "Amazon Web Services - Simple Storage Service S3"
                    }

                    guardDuty = infrastructureNode "GuarDuty" {
                        technology "S3"
                        description "Scans file upload"
                        tags "Amazon Web Services - GuardDuty"
                    }

                    simpleEmailService = infrastructureNode "Forms Runner SES" {
                       technology "SES"
                       tags "Amazon Web Services - Simple Email Service SES"
                    }

                    simpleQueueService = infrastructureNode "Forms Runner SQS" {
                       technology "SQS"
                       tags "Amazon Web Services - Simple Queue Service SQS"
                    }

                    albS3Logs = infrastructureNode "S3" {
                        technology "S3"
                        description "Stores ALB logs ingested by Cyber"
                        tags "Amazon Web Services - Simple Storage Service S3"
                    }

                    alb = infrastructureNode "Load Balancer" {
                        technology "ALB"
                        description "Distributes incoming application traffic (logs sent to S3)"
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

                    # Deployment Nodes represents infrastructure components where
                    # containers and/or services are deployed or a collection of
                    # interrelated infrastructure nodes.
                    # Named Deployment Nodes allow for relationships to exist between
                    # components.
                    cloudWatch = deploymentNode "CloudWatch" {
                        tags "Amazon Web Services - CloudWatch"
                        description "CloudWatch Services: logging, metrics, and alerts"

                        logs = infrastructureNode "CloudWatch Logs" {
                            technology "CloudWatch"
                            tags "Amazon Web Services - CloudWatch"
                        }

                        alarms = infrastructureNode "CloudWatch Alarms" {
                            technology "CloudWatch"
                            tags "Amazon Web Services - CloudWatch Alarm"
                        }

                        metrics = infrastructureNode "CloudWatch Metrics" {
                            technology "CloudWatch"
                            tags "Amazon Web Services - CloudWatch"
                        }
                    }

                    deploymentNode "ECS Fargate Forms cluster" {
                        tags "Amazon Web Services - Fargate"

                        formsAdmin = deploymentNode "Forms Admin" {
                            formsAdminContainer = containerInstance forms.formsAdmin
                            tags "Amazon Web Services - Elastic Container Service Container1"
                        }

                        formsAPI = deploymentNode "Forms API" {
                            formsAPIContainer = containerInstance forms.formsAPI
                            tags "Amazon Web Services - Elastic Container Service Container1"
                        }

                        formsProductPage = deploymentNode "Forms Product Page" {
                            formsProductPageContainer = containerInstance forms.formsProductPage
                            tags "Amazon Web Services - Elastic Container Service Container1"
                        }

                        formsRunner = deploymentNode "Forms Runner" {
                            formsRunnerContainer = containerInstance forms.formsRunner
                            tags "Amazon Web Services - Elastic Container Service Container1"
                        }

                        alb -> formsAdmin "Forwards requests to" "HTTPS"
                        alb -> formsAPI "Forwards requests to" "HTTPS"
                        alb -> formsProductPage "Forwards requests to" "HTTPS"
                        alb -> formsRunner "Forwards requests to" "HTTPS"
                        formsAdmin -> cloudWatch.metrics "Reads metrics from"
                        formsRunner -> fileUploadS3 "Writes to"
                        formsRunner -> simpleEmailService "Sends" "Completed Form"
                        formsRunner -> cloudWatch.metrics "Writes metrics to"
                    }

                    deploymentNode "RDS" {
                        tags "Amazon Web Services - RDS"
                        description "Encrypted backups retained for 7 days"

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

                    deploymentNode "Route53" {
                        tags "Amazon Web Services - Route 53"

                        dns = infrastructureNode "DNS" {
                            technology "Route 53"
                            description "Routes incoming requests based on domain name"
                            tags "Amazon Web Services - Route 53"
                        }

                        infrastructureNode "Hosted Zone" {
                            technology "Route53"
                            tags "Amazon Web Services - Route 53 Hosted Zone"
                        }

                        dns -> cloudFront "Forwards requests to" "HTTPS"
                    }

                    deploymentNode "DynamoDB" {
                        description "Stores Terraform state locking information"
                        tags "Amazon Web Services - DynamoDB"

                        infrastructureNode "Terraform State Lock" {
                            technology "DynamoDB"
                            tags "Amazon Web Services - DynamoDB Table""
                        }
                    }

                    deploymentNode "AWS Lambda" {
                        description "Lambda functions related to pipeline maintenance"
                        tags "Amazon Web Services - Lambda"

                        pausedPipelineDetector = infrastructureNode "Paused Pipeline Detector" {
                            technology "AWS Lambda"
                            description "Detects paused pipelines"
                            tags "Amazon Web Services - Lambda Lambda Function"
                        }

                        pipelineInvoker = infrastructureNode "Pipeline Invoker" {
                            technology "AWS Lambda"
                            description "Invokes a pipeline"
                            tags "Amazon Web Services - Lambda Lambda Function"
                        }

                        eventBridge -> pipelineInvoker "invokes"
                    }

                    deploymentNode "Aurora RDS Cluster" {
                        tags "Amazon Web Services - RDS Amazon Aurora instance"

                        # Nested deployment nodes allow for more precise tagging on components
                        # and better visual metadata
                        deploymentNode "Solid Queue RDS" {
                            tags "Amazon Web Services - RDS"
                            solidQueue = containerInstance forms.solidQueue
                        }

                        deploymentNode "Audit Trail RDS" {
                            tags "Amazon Web Services - RDS"
                            auditTrail = containerInstance forms.auditTrail
                        }
                    }

                    # Relationships between isolated components
                    cloudFront -> alb "Forwards requests to" "HTTPS"
                    shieldAdvanced -> cloudFront "Monitors traffic for DDoS"
                    wafRules -> cloudFront "Enforces WAF rules on traffic to"
                    alb -> albS3Logs "Sends logs to"
                    simpleEmailService -> simpleNotificationService "Talks to"
                    simpleNotificationService -> simpleQueueService "Talks to"
                    guardDuty -> fileUploadS3 "Scans"
                }
            }

            deployAccount = deploymentNode "Deploy Account" {
                tags "Amazon Web Services - Cloud"

                infrastructureNode "SSM ParameterStore" {
                    technology "ParameterStore"
                    description "Stores secrets and credentials"
                    tags "Amazon Web Services - Systems Manager Parameter Store"
                }

                infrastructureNode "Elastic Container Registry" {
                    technology "ECR"
                    description "Private image repository"
                    tags "Amazon Web Services - EC2 Container Registry"
                }

                infrastructureNode "Terraform State Lock" {
                    technology "DynamoDB"
                    tags "Amazon Web Services - DynamoDB Table""
                }

                infrastructureNode "CodeBuild" {
                    technology "CodeBuild"
                    tags "Amazon Web Services - CodeBuild"
                }

                infrastructureNode "CodePipeline" {
                    technology "CodePipeline"
                    tags "Amazon Web Services - CodePipeline"
                }

                awsDeveloperQ = infrastructureNode "AWS Developer Q" {
                    technology "AWS Developer Q"
                    description "Formally AWS ChatBot"
                    tags "CustomAWSDeveloperQIcon"
                }

                eventBridge = infrastructureNode "EventBridge" {
                    technology "EventBridge"
                    tags "Amazon Web Services - EventBridge"
                }

                deploymentNode "ECS Fargate" {
                    technology "ECS Fargate"
                    tags "Amazon Web Services - Fargate"
                    pipelineVisualiser = containerInstance forms.pipelineVisualiser
                }

            }

            allEnvironments.region.codePipeline -> deployAccount.awsDeveloperQ "Sends notification to"
        }
    }

    views {
        systemContext forms {
            include *
            autoLayout
        }

        container forms {
            include *
            exclude forms.pipelineVisualiser
            autoLayout
        }

        deployment forms formsEnvironments "FormsArchitecture" {
            include *
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

            element "CustomAWSDeveloperQIcon" {
                background #ffffff
                icon "https://d1.awsstatic.com/getting-started-guides/learning/amazon-q/icon_amazon-q.a5c38564734b6e9f611e9599eb271142389313a4.png"
            }
        }

        themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
    }

}