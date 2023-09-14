# frozen_string_literal: true

require "commands/ecs_summary"
require "utilities/printer"
require_relative "../fixtures/ecs"
require_relative "../fixtures/sts"

describe EcsSummary do
  context "when not authenticated" do
    it "prompts the user to authenticate" do
      expect { described_class.new.run }.to output(/You must be authenticated/).to_stdout
    end
  end

  context "when authenticated" do
    let(:printer_mock) do
      printer_mock = instance_double(Printer)

      allow(printer_mock)
        .to receive(:print_table)

      printer_mock
    end

    before do
      allow_any_instance_of(Helpers) # rubocop:todo RSpec/AnyInstance
        .to receive(:aws_authenticated?)
        .and_return(true)

      allow(Printer)
        .to receive(:new)
        .and_return(printer_mock)

      # stub STS
      sts_stub = instance_double(Aws::STS::Client)
      allow(Aws::STS::Client)
        .to receive(:new)
        .and_return(sts_stub)

      allow(sts_stub)
        .to receive(:get_caller_identity)
        .and_return(StsFixtures.get_caller_identity)

      # stub ECS
      ecs_stub = instance_double(Aws::ECS::Client)
      allow(Aws::ECS::Client)
        .to receive(:new)
        .and_return(ecs_stub)

      allow(ecs_stub)
        .to receive(:describe_services)
        .with({ services: %w[forms-api forms-admin forms-runner forms-product-page],
                cluster: "forms-dev" })
        .and_return(EcsFixtures.describe_services)

      allow(ecs_stub)
        .to receive(:describe_task_definition)
        .and_return(EcsFixtures.describe_task_definition)
    end

    it "prints the ECS summary" do
      described_class.new.run

      expect(printer_mock)
        .to have_received(:print_table)
        .with(
          "ECS summary for dev",
          [{ desired: 1,
             failed: 0,
             image: "forms-admin-image:tag",
             latest_event: "(service forms-admin) has reached a steady state.",
             name: "forms-admin",
             pending: 0,
             running: 1,
             state: "COMPLETED" }],
        )
    end
  end
end
