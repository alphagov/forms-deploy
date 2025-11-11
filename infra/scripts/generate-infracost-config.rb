#!/usr/bin/env ruby

require "English"
require "yaml"
require "json"
require "pathname"
require "optparse"

class InfracostConfigGenerator
  ENVIRONMENTS = %w[dev staging production user-research].freeze

  def initialize
    check_infracost_installed!
    @auto_config = get_auto_config
  end

  def generate
    config = {
      "version" => 0.1,
      "projects" => [],
    }

    config["projects"].concat(generate_forms_projects)
    config["projects"].concat(generate_deploy_projects)
    config["projects"].concat(generate_integration_projects)

    # Sort projects by name for consistent ordering
    config["projects"].sort_by! { |project| project["name"] }

    # Sort arrays within each project for consistent ordering
    config["projects"].each do |project|
      sort_project_arrays!(project)
    end

    config
  end

private

  def check_infracost_installed!
    return if system("which infracost > /dev/null 2>&1")

    raise "Error: 'infracost' command not found. Please install infracost first.\n" \
          "See: https://www.infracost.io/docs/#quick-start"
  end

  def sort_project_arrays!(project)
    # Sort terraform_var_files array if it exists
    project["terraform_var_files"]&.sort!

    # Sort dependency_paths array if it exists
    project["dependency_paths"]&.sort!
  end

  def directory_has_files?(path)
    Dir.glob("#{path}/**/*").any? { |f| File.file?(f) }
  end

  def get_auto_config
    result = `infracost generate config --repo-path . 2>/dev/null`
    return {} if $CHILD_STATUS.exitstatus != 0

    begin
      YAML.safe_load(result)
    rescue StandardError => e
      warn "Warning: Failed to parse infracost auto-config: #{e.message}"
      {}
    end
  end

  def find_dependency_paths(project_path)
    auto_projects = @auto_config["projects"] || []
    matching_project = auto_projects.find { |p| p["path"] == project_path }
    raw_paths = matching_project&.dig("dependency_paths") || []

    # Remove all .tfvars files from dependency paths
    raw_paths.reject { |path| path.end_with?(".tfvars") }
  end

  def generate_dependency_paths_with_tfvars(project_path, terraform_var_files)
    base_dependency_paths = find_dependency_paths(project_path)

    # Convert terraform_var_files to paths relative to repo root
    project_pathname = Pathname.new(project_path)
    repo_root = Pathname.new(".")

    tfvar_paths = terraform_var_files.map do |var_file|
      # Resolve the var file path relative to the project, then relative to repo root
      (project_pathname + var_file).relative_path_from(repo_root).to_s
    end

    base_dependency_paths + tfvar_paths
  end

  def generate_forms_projects
    projects = []

    forms_roots = Dir.glob("infra/deployments/forms/*")
                     .select { |path| File.directory?(path) }
                     .select { |path| directory_has_files?(path) }
                     .map { |path| File.basename(path) }
                     .reject { |root| root == "tfvars" || root.start_with?(".") }
                     .sort

    forms_roots.each do |root|
      ENVIRONMENTS.each do |env|
        project_path = "infra/deployments/forms/#{root}"

        project = {
          "path" => project_path,
          "name" => "forms-#{root}-#{env}",
          "skip_autodetect" => true,
        }

        # Add terraform_var_files based on root type
        if root == "account"
          terraform_var_files = [
            "tfvars/#{env}.tfvars",
            "tfvars/backends/#{env}.tfvars",
          ]
        else
          terraform_var_files = [
            "../tfvars/#{env}.tfvars",
            "../account/tfvars/backends/#{env}.tfvars",
          ]

          if root == "pipelines"
            terraform_var_files << "tfvars/#{env}.tfvars"
          end
        end

        project["terraform_var_files"] = terraform_var_files

        # Add usage_file if infracost-usage.yml exists in the project directory
        usage_file_path = File.join(project_path, "infracost-usage.yml")
        if File.exist?(usage_file_path)
          project["usage_file"] = "infracost-usage.yml"
        end

        # Generate dependency_paths with .tfvars files filtered and re-added with correct paths
        dependency_paths = generate_dependency_paths_with_tfvars(project_path, terraform_var_files)
        unless dependency_paths.empty?
          project["dependency_paths"] = dependency_paths
        end

        projects << project
      end
    end

    projects
  end

  def generate_deploy_projects
    projects = []

    deploy_roots = Dir.glob("infra/deployments/deploy/*")
                      .select { |path| File.directory?(path) }
                      .select { |path| directory_has_files?(path) }
                      .map { |path| File.basename(path) }
                      .reject { |root| root.start_with?(".") }
                      .sort

    deploy_roots.each do |root|
      project_path = "infra/deployments/deploy/#{root}"

      project = {
        "path" => project_path,
        "name" => "deploy-#{root}",
        "skip_autodetect" => true,
      }

      # Add usage_file if infracost-usage.yml exists in the project directory
      usage_file_path = File.join(project_path, "infracost-usage.yml")
      if File.exist?(usage_file_path)
        project["usage_file"] = "infracost-usage.yml"
      end

      # Generate dependency_paths (deploy projects don't typically have terraform_var_files)
      dependency_paths = find_dependency_paths(project_path)
      unless dependency_paths.empty?
        project["dependency_paths"] = dependency_paths
      end

      projects << project
    end

    projects
  end

  def generate_integration_projects
    projects = []

    # Main integration roots
    integration_roots = Dir.glob("infra/deployments/integration/*")
                           .select { |path| File.directory?(path) }
                           .select { |path| directory_has_files?(path) }
                           .map { |path| File.basename(path) }
                           .reject { |root| root == "tfvars" || root.start_with?(".") }
                           .sort

    integration_roots.each do |root|
      project_path = "infra/deployments/integration/#{root}"
      terraform_var_files = [
        "../tfvars/integration.tfvars",
        "../tfvars/backend/integration.tfvars",
      ]

      project = {
        "path" => project_path,
        "name" => "integration-#{root}",
        "skip_autodetect" => true,
        "terraform_var_files" => terraform_var_files,
      }

      # Add usage_file if infracost-usage.yml exists in the project directory
      usage_file_path = File.join(project_path, "infracost-usage.yml")
      if File.exist?(usage_file_path)
        project["usage_file"] = "infracost-usage.yml"
      end

      # Generate dependency_paths with .tfvars files filtered and re-added with correct paths
      dependency_paths = generate_dependency_paths_with_tfvars(project_path, terraform_var_files)
      unless dependency_paths.empty?
        project["dependency_paths"] = dependency_paths
      end

      projects << project
    end

    projects
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}

  OptionParser.new { |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

    opts.on("-o", "--output PATH", "Write output to file instead of stdout") do |path|
      options[:output] = path
    end

    opts.on("-h", "--help", "Show this help message") do
      puts opts
      exit
    end
  }.parse!

  generator = InfracostConfigGenerator.new
  config = generator.generate
  yaml_output = config.to_yaml

  if options[:output]
    File.write(options[:output], yaml_output)
    puts "Generated infracost config written to #{options[:output]}"
  else
    puts yaml_output
  end
end
