# frozen_string_literal: true

require "time"
require "aws-sdk-ecs"

# Fixtures for ECS api calls
module EcsFixtures
  @ecs_client_stub = Aws::ECS::Client.new({ stub_responses: true })

  def self.describe_services
    @ecs_client_stub.stub_data(
      :describe_services,
      { services: [{ service_arn: "forms-admin-service-arn",
                     service_name: "forms-admin",
                     cluster_arn: "forms-admin-cluster",
                     load_balancers: [{
                       target_group_arn: "forms-admin-target", container_name: "forms-admin", container_port: 3000
                     }],
                     service_registries: [],
                     status: "ACTIVE",
                     desired_count: 1,
                     running_count: 1,
                     pending_count: 0,
                     launch_type: "FARGATE",
                     platform_version: "1.4.0",
                     platform_family: "Linux",
                     task_definition: "forms-admin-task-definition",
                     deployment_configuration: { deployment_circuit_breaker: { enable: false, rollback: false },
                                                 maximum_percent: 200,
                                                 minimum_healthy_percent: 100 },
                     deployments: [{ id: "deployment-id",
                                     status: "PRIMARY",
                                     task_definition: "task-definition",
                                     desired_count: 1,
                                     pending_count: 0,
                                     running_count: 1,
                                     failed_tasks: 0,
                                     created_at: Time.parse("2023-01-01"),
                                     updated_at: Time.parse("2023-01-01"),
                                     launch_type: "FARGATE",
                                     platform_version: "1.4.0",
                                     platform_family: "Linux",
                                     network_configuration: { awsvpc_configuration: {
                                       subnets: %w[subnets], security_groups: %w[security-group], assign_public_ip: "DISABLED"
                                     } },
                                     rollout_state: "COMPLETED",
                                     rollout_state_reason: "completed" }],
                     role_arn: "role-arn",
                     events: [{ id: "id", created_at: Time.parse("2023-01-01"), message: "(service forms-admin) has reached a steady state." },
                              { id: "fac95ea0-316f-4fdf-a200-f2b1f31f97ac",
                                created_at: Time.parse("2023-01-02"),
                                message: "(service forms-admin) has reached a steady state." },
                              { id: "38c4d986-a847-47b6-b9fc-ac4b6d5b0a33",
                                created_at: Time.parse("2023-01-03"),
                                message: "(service forms-admin) has reached a steady state." },
                              { id: "d5361915-43f7-4d9c-9ba1-0df2649372f2",
                                created_at: Time.parse("2023-01-04"),
                                message: "(service forms-admin) has reached a steady state." }],
                     created_at: Time.parse("2023-01-05"),
                     placement_constraints: [],
                     placement_strategy: [],
                     network_configuration: { awsvpc_configuration: {
                       subnets: %w[subnets], security_groups: %w[security-group], assign_public_ip: "DISABLED"
                     } },
                     health_check_grace_period_seconds: 0,
                     scheduling_strategy: "REPLICA",
                     deployment_controller: { type: "ECS" },
                     created_by: "deployer-name",
                     enable_ecs_managed_tags: false,
                     propagate_tags: "NONE",
                     enable_execute_command: false }],
        failures: [] },
    )
  end

  def self.describe_task_definition
    @ecs_client_stub.stub_data(
      :describe_task_definition,
      { task_definition: { task_definition_arn: "task-arn",
                           container_definitions: [{ name: "forms-admin",
                                                     image: "some-registry/forms-admin-image:tag",
                                                     cpu: 0,
                                                     port_mappings: [{ container_port: 3000,
                                                                       host_port: 3000,
                                                                       protocol: "tcp" }],
                                                     essential: true,
                                                     environment: [{ name: "SOME_SETTING", value: "false" }],
                                                     mount_points: [],
                                                     volumes_from: [],
                                                     secrets: [{ name: "SOME_SECRET",
                                                                 value_from: "some_value_arn" }],
                                                     log_configuration: { log_driver: "awslogs",
                                                                          options: { "awslogs-group" => "forms-admin-dev",
                                                                                     "awslogs-region" => "eu-west-2",
                                                                                     "awslogs-stream-prefix" => "forms-admin-dev" } } }],
                           family: "dev_forms-admin",
                           task_role_arn: "role-arn",
                           execution_role_arn: "execution-arn",
                           network_mode: "awsvpc",
                           revision: 124,
                           volumes: [],
                           status: "ACTIVE",
                           requires_attributes: [{ name: "some-attribute" }],
                           placement_constraints: [],
                           compatibilities: %w[EC2 FARGATE],
                           runtime_platform: {
                             cpu_architecture: "ARM64", operating_system_family: "LINUX"
                           },
                           requires_compatibilities: %w[FARGATE],
                           cpu: "256",
                           memory: "512",
                           registered_at: Time.parse("2023-01-01"),
                           registered_by: "deploying-user" },
        tags: [] },
    )
  end
end
