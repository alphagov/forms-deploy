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

            hostedZone = container "Hosted Zone" {
                technology "Route53"
                tags "Amazon Web Services - Route 53 Hosted Zone"
            }

            dns = container "DNS" {
                technology "Route 53"
                description "Routes incoming requests based upon domain name"
                tags "Amazon Web Services - Route 53"
            }

            terraformStateLock = container "Terraform State Lock" {
                technology "DynamoDB"
                tags "Amazon Web Services - DynamoDB Table""
            }

            pausedPipelineDetector = container "Paused Pipeline Detector" {
                technology "AWS Lambda"
                description "Detects paused pipelines"
                tags "Amazon Web Services - Lambda Lambda Function"
            }

            pipelineInvoker = container "Pipeline Invoker" {
                technology "AWS Lambda"
                description "Invokes a pipeline"
                tags "Amazon Web Services - Lambda Lambda Function"
            }

            solidQueue = container "Solid Queue" {
                technology "Postgres"
                tags "Database"
            }

            auditTrail = container "Forms Runner Audit Trail" {
                technology "Postgres"
                tags "Database"
            }

            pipelineVisualiser = container "Pipeline Visualiser" {
                technology "Sinatra"
                tags "Application"
            }

            # Relationships
            # <source> -> <destination> "Description" "Protocol/technology (optional)"
            formsAdmin -> usersDB "Reads from and writes to" "PostgreSQL Protocol/SSL"
            formsAPI -> formsDefinitionsDB "Reads from and writes to" "PostgreSQL Protocol/SSL"
            formsRunner -> sessionsDB "Reads from and writes to" "Redis"
            formsRunner -> cloudWatchMetrics "Writes metrics to"
            formsRunner -> solidQueue "Writes to"
            formsAdmin -> cloudWatchMetrics "Reads metrics from"
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

                    sesForOTP = infrastructureNode "SES" {
                        technology "SES"
                        description "Sends OTP emails for admin onboarding"
                        tags "Amazon Web Services - Simple Email Service SES"
                    }

                    albS3Logs = infrastructureNode "S3" {
                        technology "S3"
                        description "Stores ALB logs ingested by Cyber"
                        tags "Amazon Web Services - Simple Storage Service S3"
                    }

                    codeBuild = infrastructureNode "CodeBuild" {
                        technology "CodeBuild"
                        tags "Amazon Web Services - CodeBuild"
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

                    simpleNotificationService = infrastructureNode "Forms Runner SNS" {
                       technology "SNS"
                       tags "Amazon Web Services - Simple Notification Service SNS"
                    }

                    # Deployment Nodes represents infrastructure components where
                    # containers and/or services are deployed or a collection of
                    # interrelated infrastructure components.
                    # Named Deployment Nodes allow for relationships to exist between
                    # components.
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
                        formsRunner -> fileUploadS3 "Writes to"
                        formsRunner -> simpleEmailService "Sends" "Completed Form"
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

                    deploymentNode "CloudWatch" {
                        tags "Amazon Web Services - CloudWatch"
                        description "CloudWatch Services: logging, metrics, and alerts"

                        logs = containerInstance forms.cloudWatchLogs
                        alarms = containerInstance forms.cloudWatchAlarms
                        metrics = containerInstance forms.cloudWatchMetrics
                    }

                    deploymentNode "Route53" {
                        tags "Amazon Web Services - Route 53"

                        hostedZone = containerInstance forms.hostedZone
                        dns = containerInstance forms.dns

                        dns -> cloudFront "Forwards requests to" "HTTPS"
                    }

                    deploymentNode "DynamoDB" {
                        description "Stores Terraform state locking information"
                        tags "Amazon Web Services - DynamoDB"

                        terraformStateLock = containerInstance forms.terraformStateLock
                    }

                    deploymentNode "AWS Lambda (pipelines)" {
                        description "Lambda functions related to pipeline maintenance"
                        tags "Amazon Web Services - Lambda"

                        pausedPipelineDetector = containerInstance forms.pausedPipelineDetector
                        pipelineInvoker = containerInstance forms.pipelineInvoker

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
        deployment forms formsEnvironments "FormsArchitecture" {
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

            element "CustomAWSDeveloperQIcon" {
                background #ffffff
                icon "https://d1.awsstatic.com/getting-started-guides/learning/amazon-q/icon_amazon-q.a5c38564734b6e9f611e9599eb271142389313a4.png"
            }
        }

        themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
    }

}