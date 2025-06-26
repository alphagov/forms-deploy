workspace "GOV.UK Forms" "An MVP architecture." {

    !identifiers hierarchical

    model {
        form_creator = person "Form Creator" "A civil servant managing forms"
        form_submitter = person "Form Submitter" "A member of the public submitting a form"
        form_processor = person "Form Processor" "A civil servant processing form submissions"
        // form_super_admin = person "GOV.UK Forms Super Admin" "A member of the GOV.UK Forms team with the super admin role"
        // form_developer = person "GOV.UK Forms Developer" "A developer on the GOV.UK Forms team"

        forms = softwareSystem "GOV.UK Forms" {
            # Containers: represent a deployable unit that contributes to the functionality of the system (e.g., web app, db)
            forms_admin = container "forms-admin" {
                technology "Ruby on Rails"
                tags "Application"
                description "Manages form creation on the platform, including user, group, and MOU management"
            }

            forms_api = container "forms-api" {
                technology "Ruby on Rails"
                tags "Application"
                description "Serves form snapshots for preview, live, and archived forms"
            }

            forms_product_page = container "forms-product-page" {
                technology "Ruby on Rails"
                tags "Application"
                description "Hosts content for onboarding new users of GOV.UK Forms, and supporting pages"
            }

            forms_runner = container "forms-runner" {
                technology "Ruby on Rails"
                tags "Application"
                description "Serves forms and handles form submissions"
            }

            forms_admin_db = container "forms-admin-database" {
                technology "Postgres"
                tags "Database"
                description "Stores organisations, users, groups, and MOU signatures"
            }

            forms_runner_db = container "forms-runner-database" {
                technology "Postgres"
                tags "Database"
                description "Stores form submissions"
            }

            forms_api_db = container "forms-api-database" {
                technology "Postgres"
                tags "Database"
                description "Stores forms and made live form snapshots"
            }

            sessions_db = container "forms-sessions-db" {
                technology "Redis"
                description "Stores session including form answers, with 20 hours expiry"
                tags "Database"
            }

            solidqueue = container "submissions-solidqueue" {
                technology "Postgres"
                tags "Database"
                description "Queues submissions for asynchronous processing"
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
            // form_super_admin -> forms_admin "Manages the forms platform"

            form_creator -> forms_admin "Creates, edits, and manages forms"
            form_creator -> forms_product_page "Learns from"
            form_creator -> forms_runner "Previews forms"

            form_submitter -> forms_runner "Fills out and submits forms"

            solidqueue -> form_processor "Receives and processes form submissions"

            forms_admin -> forms_admin_db "Reads from and writes to" "PostgreSQL Protocol/SSL"
            forms_admin -> forms_api "Reads from and writes to" "ActiveResource"
            forms_runner -> forms_api "Reads from and writes to" "ActiveResource"
            forms_runner -> sessions_db "Reads from and writes to" "Redis"
            forms_runner -> solidqueue "Reads from and writes to" "Solidqueue"
            forms_runner -> forms_runner_db "Reads from and writes to"
            forms_runner -> auditTrail "Writes to"
            solidqueue -> forms_runner_db "Reads from and writes to"
            forms_api -> forms_api_db "Reads from and writes to" "PostgreSQL Protocol/SSL"

        }

        pay = softwareSystem "GOV.UK Pay" {
            tags "External"
        }
        notify = softwareSystem "GOV.UK Notify" {
            tags "External"
        }
        auth0 = softwareSystem "Auth0" {
            tags "External"
        }

        // form_developer -> forms "Maintains"


        forms -> pay "Manages payments"
        form_submitter -> pay "Makes payments"
        forms -> notify "Sends confirmation emails"
        notify -> form_submitter "Receives confirmation email"
        form_creator -> auth0 "Authenticates"


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

                        forms_admin = deploymentNode "Forms Admin" {
                            forms_adminContainer = containerInstance forms.forms_admin
                            tags "Amazon Web Services - Elastic Container Service Container1"
                        }

                        forms_api = deploymentNode "Forms API" {
                            forms_apiContainer = containerInstance forms.forms_api
                            tags "Amazon Web Services - Elastic Container Service Container1"
                        }

                        forms_product_page = deploymentNode "Forms Product Page" {
                            forms_product_pageContainer = containerInstance forms.forms_product_page
                            tags "Amazon Web Services - Elastic Container Service Container1"
                        }

                        forms_runner = deploymentNode "Forms Runner" {
                            forms_runnerContainer = containerInstance forms.forms_runner
                            tags "Amazon Web Services - Elastic Container Service Container1"
                        }

                        alb -> forms_admin "Forwards requests to" "HTTPS"
                        alb -> forms_api "Forwards requests to" "HTTPS"
                        alb -> forms_product_page "Forwards requests to" "HTTPS"
                        alb -> forms_runner "Forwards requests to" "HTTPS"
                        forms_admin -> cloudWatch.metrics "Reads metrics from"
                        forms_runner -> fileUploadS3 "Writes to"
                        forms_runner -> simpleEmailService "Sends" "Completed Form"
                        forms_runner -> cloudWatch.metrics "Writes metrics to"
                    }

                    deploymentNode "RDS" {
                        tags "Amazon Web Services - RDS"
                        description "Encrypted backups retained for 7 days"

                        deploymentNode "Users DB" {
                            tags "Amazon Web Services - RDS Postgres instance"
                            forms_admin_db = containerInstance forms.forms_admin_db
                        }

                        deploymentNode "Forms Definitions DB" {
                            tags "Amazon Web Services - RDS Postgres instance"
                            forms_api_db = containerInstance forms.forms_api_db
                        }
                    }

                    deploymentNode "Elasticache" {
                        tags "Amazon Web Services - ElastiCache"
                        sessions_db = containerInstance forms.sessions_db
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
                            solidqueue = containerInstance forms.solidqueue
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

    configuration {
        scope softwaresystem
    }
}
