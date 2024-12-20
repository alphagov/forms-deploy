require "open3"

require_relative "../lib/terraform_checker"

describe "#remind_to_connect_vpn" do
  context "when the user runs the script" do
    it "prints a reminder to connect to the VPN" do
      expect { remind_to_connect_vpn }
          .to output("Reminder: you must be connected to the VPN to run `terraform plan` in the deploy account.\n")
          .to_stdout
    end
  end
end

describe "#aws_session_active?" do
  context "when the user is connected to a secure AWS session" do
    it "returns true" do
      success_output = <<~OUTPUT
        {
          "UserId": "AIDXXXXXXXXXXXX/YourUserName",
          "Account": "123456789012",
          "Arn": "arn:aws:iam::123456789012:user/YourUserName"
        }
      OUTPUT

      allow(Open3).to receive(:capture3)
        .with("aws sts get-caller-identity")
        .and_return([success_output, "", double(success?: true)])

      result = aws_session_active?

      expect(result).to be true
    end

    it "returns false" do
      allow(Open3).to receive(:capture3)
         .with("aws sts get-caller-identity")
         .and_return(["", "An error occurred", double(success?: false)])

      result = aws_session_active?

      expect(result).to be false
    end
  end
end

describe "#create_roots_list" do
  context "when there are roots in the `deploy` directory" do
    it "returns a list of roots" do
      allow(Dir).to receive(:children).with("deploy").and_return(%w[root1 root2])
      allow(File).to receive(:directory?).with("deploy/root1").and_return(true)
      allow(File).to receive(:directory?).with("deploy/root2").and_return(true)

      result = create_roots_list("deploy")

      expect(result).to eq(%w[root1 root2])
    end

    it "does not return files in the list of roots" do
      allow(Dir).to receive(:children).with("deploy").and_return(["root1", "root2", "file.tf"])
      allow(File).to receive(:directory?).with("deploy/root1").and_return(true)
      allow(File).to receive(:directory?).with("deploy/root2").and_return(true)
      allow(File).to receive(:directory?).with("deploy/file.tf").and_return(false)

      result = create_roots_list("deploy")

      expect(result).to eq(%w[root1 root2])
    end
  end

  context "when there are no roots in the `deploy` directory" do
    it "prints an error message and exits the script" do
      allow(Dir).to receive(:children).with("deploy").and_return([])

      expect { create_roots_list("deploy") }
        .to output("Error: No roots found in the directory 'deploy'. Exiting script.\n")
        .to_stdout
        .and raise_error(SystemExit)
    end
  end

  context "when there are hidden files or directories" do
    it "ignores hidden directories and files in the `deploy` directory" do
      allow(Dir).to receive(:children).with("deploy").and_return([".hidden", "root1"])
      allow(File).to receive(:directory?).with("deploy/.hidden").and_return(true)
      allow(File).to receive(:directory?).with("deploy/root1").and_return(true)

      result = create_roots_list("deploy")

      expect(result).to eq(%w[root1])
    end
  end
end

describe "#run_terraform_plan" do
  context "when `deploy` directory contains roots" do
    it "executes the make command for each root in the list" do
      project_root = File.expand_path("../../..", __dir__)

      roots = %w[root1 root2]

      allow(self).to receive(:`).and_return("No changes. Your infrastructure matches the configuration.")

      run_terraform_plan(roots)

      expect(self).to have_received(:`).exactly(roots.size).times

      roots.each do |root|
        expect(self).to have_received(:`).with("make -C #{project_root} deploy deploy/#{root} plan")
      end
    end
  end

  it "exits with an error message when the `make` command fails for a root" do
    roots = %w[root1 root2]

    root_directory = File.expand_path("../../..", __dir__)

    allow(self).to receive(:`).with("make -C #{root_directory} deploy deploy/root1 plan")
      .and_raise(StandardError, "Command execution failed")

    expect {
      run_terraform_plan(roots)
    }.to output(/Error processing root1: Command execution failed/).to_stdout
      .and raise_error(SystemExit)
  end

  context "when the `deploy` directory is empty" do
    it "does nothing if no roots are passed" do
      expect { run_terraform_plan([]) }
        .to output("No roots to plan, please check there are roots in the `deploy` directory\n")
        .to_stdout
        .and raise_error(SystemExit)
    end
  end
end

describe "#changes_required?" do
  it "returns true when the output contains text indicating changes are required" do
    output = "Plan: 1 to add, 0 to change, 0 to destroy"
    expect(changes_required?(output)).to be true
  end

  it "returns false when the output contains text 'No changes'" do
    output = "No changes"
    expect(changes_required?(output)).to be false
  end

  it "prints error message and exits when output is nil" do
    expect { changes_required?(nil) }
      .to output("Terraform output is invalid, exiting script\n")
      .to_stdout
      .and raise_error(SystemExit)
  end

  it "prints error message and exits when output is empty string" do
    expect { changes_required?("") }
      .to output("Terraform output is invalid, exiting script\n")
      .to_stdout
      .and raise_error(SystemExit)
  end
end

describe "#print_running_message" do
  it "prints which root is being run in the `terraform plan`" do
    root = "root1"

    expected_output = "Running `terraform plan` on #{root}\n"

    expect { print_running_message(root) }.to output(expected_output).to_stdout
  end
end

describe "#print_summary_message" do
  context "when there are roots requiring changes" do
    it "prints which roots require manual `terraform apply` commands" do
      roots_requiring_changes = %w[root1 root2]

      expected_output = "\nRoots requiring manual `terraform apply`:\nroot1\nroot2\n"

      expect { print_summary_message(roots_requiring_changes) }.to output(expected_output).to_stdout
    end
  end

  context "when there are no roots requiring changes" do
    it "prints which roots require manual `terraform apply` commands" do
      roots_requiring_changes = []

      expected_output = "No changes required in `deploy` roots\n Drink some water, stay kind to yourself, and remember to breathe.\n You're doing great.\n"

      expect { print_summary_message(roots_requiring_changes) }.to output(expected_output).to_stdout
    end
  end
end

describe "#main" do
  it "orchestrates the flow correctly" do
    allow(self).to receive(:remind_to_connect_vpn)
    allow(self).to receive(:aws_session_active?).and_return(true)
    allow(self).to receive(:create_roots_list).and_return(%w[root1 root2])
    allow(self).to receive(:run_terraform_plan)

    expect { main }.not_to raise_error

    expect(self).to have_received(:remind_to_connect_vpn)
    expect(self).to have_received(:aws_session_active?)
    expect(self).to have_received(:create_roots_list)
    expect(self).to have_received(:run_terraform_plan).with(%w[root1 root2])
  end

  it "exits with an error message when AWS session is inactive" do
    allow(self).to receive(:remind_to_connect_vpn)
    allow(self).to receive(:aws_session_active?).and_return(false)

    expect { main }
      .to output("You must have an active 'deploy' account AWS session. Run `gds aws forms-deploy-support --shell` and run the script again.\n")
      .to_stdout
      .and raise_error(SystemExit)
  end

  it "prints a message and does not call run_terraform_plan when no roots are found" do
    directory = File.expand_path("../../../infra/deployments/deploy", __dir__)

    allow(self).to receive(:remind_to_connect_vpn)
    allow(self).to receive(:aws_session_active?).and_return(true)
    allow(self).to receive(:create_roots_list).and_raise(SystemExit, "Error: No roots found in the directory '#{directory}'. Exiting script.")

    expect { main }
      .to output("Error: No roots found in the directory '#{directory}'. Exiting script.")
      .to_stdout

    expect(self).not_to have_received(:run_terraform_plan)
  end
end

#### Helper method

def mock_make_output(outputs)
  allow(self).to receive(:`) do |command|
    root = command.match(/deploy\/(\w+)/)[1]
    outputs[root]
  end
end
