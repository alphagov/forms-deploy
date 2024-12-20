require "open3"

def main
  remind_to_connect_vpn

  ensure_aws_session_active

  roots = create_roots_list("../../infra/deployments/deploy/")

  run_terraform_plan(roots)
end

def remind_to_connect_vpn
  puts "Reminder: you must be connected to the VPN to run `terraform plan` in the deploy account.\n"
end

def aws_session_active?
  _stdout, _stderr, status = Open3.capture3("aws sts get-caller-identity")
  status.success?
end

def create_roots_list(directory)
  roots = Dir.children(directory).select { |entry| !entry.start_with?(".") && File.directory?(File.join(directory, entry)) }

  if roots.empty?
    puts "Error: No roots found in the directory '#{directory}'. Exiting script."
    exit(1)
  end

  roots
end

def run_terraform_plan(roots)
  validate_roots(roots)

  roots_requiring_changes = []
  root_directory = File.expand_path("../../..", __dir__)

  roots.each do |root|
    process_root(root, root_directory, roots_requiring_changes)
  end

  print_summary_message(roots_requiring_changes)
end

def changes_required?(output)
  if output.nil? || output.empty?
      puts "Terraform output is invalid, exiting script"
      exit(1)
  end

  !output.include?("No changes")
end

def print_running_message(root)
  puts "Running `terraform plan` on #{root}"
end

def print_summary_message(roots_requiring_changes)
  puts roots_requiring_changes.empty? ? "No changes required in `deploy` roots\n Drink some water, stay kind to yourself, and remember to breathe.\n You're doing great." : "\nRoots requiring manual `terraform apply`:\n#{roots_requiring_changes.join("\n")}"
end

private

def ensure_aws_session_active
  unless aws_session_active?
    puts "You must have an active 'deploy' account AWS session. Run `gds aws forms-deploy-support --shell` and run the script again."
    exit(1)
  end
end

def validate_roots(roots)
  if roots.empty?
    puts "No roots to plan, please check there are roots in the `deploy` directory"
    exit(1)
  end
end

def process_root(root, root_directory, roots_requiring_changes)
  print_running_message(root)

  output = execute_terraform_plan(root, root_directory)

  roots_requiring_changes.append(root) if changes_required?(output)
rescue StandardError => e
  handle_root_error(root, e)
end

def execute_terraform_plan(root, root_directory)
  `make -C #{root_directory} deploy deploy/#{root} plan`
end

def handle_root_error(root, exception)
  puts "Error processing #{root}: #{exception.message}"
  exit(1)
end

main if __FILE__ == $PROGRAM_NAME
