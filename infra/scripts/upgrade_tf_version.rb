#! /usr/bin/env ruby

require "date"
require "English"
require "json"
require "net/http"
require "optparse"
require "pathname"
require "tmpdir"
require "yaml"

####
# Paths and helpers
####
def repo_path(path)
  repo_root = File.expand_path("../../", __dir__)
  File.expand_path(path, repo_root)
end
versions_file_path = repo_path("infra/shared/versions.tf.json")

def json_dig(file, dig_args)
  json_hash = JSON.parse File.read(file)
  json_hash.dig(*dig_args)
end

def latest_github_release(url, allow_prerelease)
  JSON.parse(
    Net::HTTP.get(URI.parse(url)),
  )
      .sort_by { |release| Gem::Version.new(release["name"][1..]) } # Gem::Version is semver, so are Terraform versions
      .reverse
      .filter { |release|
        if allow_prerelease
          release["draft"] == false
        else
          release["draft"] == false && release["prerelease"] == false
        end
      }
      .first
end

def github_release_exist?(url)
  resp = Net::HTTP.get_response(URI.parse(url))
  resp.code.to_i >= 200 && resp.code.to_i < 300
end

def canonical_provider_source(provider_config)
  provider_config["source"]
end

def latest_provider_version(provider_name)
  provider_json = JSON.parse(
    Net::HTTP.get(URI.parse("https://registry.terraform.io/v1/providers/#{provider_name}")),
  )

  provider_json["versions"]
    .map { |v| Gem::Version.new(v) }
    .sort
    .reverse
    .first
end

# @param [String] path
# @param [Gem::Requirement] terraform_constraint Constraint to use for Terraform version
# @param [Hash<String,Gem::Requirement>] provider_constraints Hash of provider "source" to "version" constraint to use
# @param [Hash<String,String>] provider_source_to_name_map Hash of provider source to provider name
def set_terraform_version_constraints(path, terraform_constraint, provider_constraints, provider_source_to_name_map)
  json_hash = JSON.parse File.read(path)

  json_hash["terraform"]["required_version"] = terraform_constraint
  json_hash["terraform"]["required_providers"] = {}

  provider_constraints.each_pair do |source, constraint|
    friendly_name = provider_source_to_name_map[source]
    json_hash["terraform"]["required_providers"][friendly_name] = {
      source:,
      version: constraint.to_s,
    }
  end

  File.write path, JSON.pretty_generate(json_hash)
end

def tfenv(*args)
  system("tfenv", *args)
  raise "tfenv invocation failed: tfenv #{args}" unless $CHILD_STATUS.exitstatus.zero?
end

def set_codebuild_terraform_version(path, latest_tf_version)
  json_hash = JSON.parse File.read(path)
  json_hash["variable"]["terraform_version"]["default"] = latest_tf_version
  File.write path, JSON.pretty_generate(json_hash)
end

def set_github_actions_version_constraint(gha_workflow_path, new_tf_constraint)
  # Ruby is perfectly capable of parsing and generating YAML
  # however it will convert the word "on" to "true".
  # "on" is a key used in GitHub Actions workflow files and
  # changing it to true breaks the workflow.
  #
  # We could call out to YQ to manipulate YAML for us, but there is a bug with
  # the YAML parser it uses that causes it to mangle multi-line strings
  # https://github.com/mikefarah/yq/discussions/1584
  #
  # Instead we use sed to find and replace a specific string. It's not perfect.
  system("sed", "-E", "-i", ".bak", "s#^[[:space:]]{2}TF_VERSION\: \"(.*)\"$#  TF_VERSION: \"#{new_tf_constraint}\"#g;", gha_workflow_path)
  raise "sed invocation failed" unless $CHILD_STATUS.exitstatus.zero?
end

def terraform(env_vars, *args)
  system(env_vars, "terraform", *args)
  raise "Terraform invocation failed: terraform #{args}" unless $CHILD_STATUS.exitstatus.zero?
end

def upgrade_terraform_root(root, plugin_cache_dir)
  # Terraform upgrades can sporadically fail
  # because of failed network requests, so we should
  # always retry
  max_retries = 3
  attempts = 0
  success = false
  env_vars = {
    "TF_PLUGIN_CACHE_DIR" => plugin_cache_dir,
  }
  while !success && (attempts < max_retries)
    attempts += 1

    begin
      FileUtils.remove_dir File.join(root, ".terraform/") if Dir.exist? File.join(root, ".terraform/")

      terraform env_vars, "-chdir=#{root}", "init", "-backend=false", "-upgrade"
      terraform env_vars,
                "-chdir=#{root}",
                "providers",
                "lock",
                "-platform=linux_arm64",
                "-platform=linux_amd64",
                "-platform=darwin_amd64",
                "-platform=windows_amd64"

      success = true
    rescue RuntimeError => e
      puts "Upgrade attempt #{attempts}/#{max_retries} failed"
      puts e.message
      sleep 5
    end
  end

  raise "Upgrading #{root} failed after #{attempts} attempts" unless success
end

####
# Options parsing
####
options = {
  allow_prerelease: false,
  force: false,
  terraform_version: nil,
}

OptionParser.new { |opts|
  opts.banner = "Usage upgrade_tf_version.rb [options]"

  opts.on("-p", "--allow-prerelease", "Allow pre-release versions to be selected") do
    options[:allow_prerelease] = true
  end

  opts.on("-f", "--force", "Perform upgrade procedure even if no upgrades are needed") do
    options[:force] = true
  end

  opts.on("--tf-version VERSION", String,
          # Multiple lines of help text make it nicely formatted
          "Set the exact version of Terraform to install.",
          "VERSION can be in the format v1.2.3 or 1.2.3.") do |value|
    options[:terraform_version] = value
  end
}.parse!

####
# Preflight checks
####
def program_installed?(program)
  `command -v #{program} >/dev/null`
  $CHILD_STATUS.exitstatus.zero?
end

raise "You must have tfenv installed" unless program_installed? "tfenv"
raise "You must have yq installed" unless program_installed? "yq"

if ENV.include? "TFENV_TERRAFORM_VERSION"
  warn <<~MSG
    You have the TFENV_TERRAFORM_VERSION environment variable set. This overrides
    the version of Terraform being supplied by tfenv and will cause this script to
    fail. You should unset it by running 'unset TFENV_TERRAFORM_VERSION'.
  MSG

  raise "TFENV_TERRAFORM_VERSION must not be set"
end

####
# Upgrade procedure
####

# @type [Gem::Version]
target_terraform_version = nil
current_tf_version_constraint = Gem::Requirement.new(
  json_dig(versions_file_path, %w[terraform required_version]),
)

if options[:terraform_version].nil?
  puts "Getting latest Terraform version..."

  latest_tf_release = latest_github_release("https://api.github.com/repos/hashicorp/terraform/releases", options[:allow_prerelease])
  latest_tf_version = Gem::Version.new(latest_tf_release["name"][1..])
  target_terraform_version = latest_tf_version
else
  puts "Checking that Terraform version #{options[:terraform_version]} exists"
  requested_tf_version = options[:terraform_version]
  version_tag = requested_tf_version[0] == "v" ? requested_tf_version : "v#{requested_tf_version}"

  if github_release_exist?("https://api.github.com/repos/hashicorp/terraform/releases/tags/#{version_tag}")
    target_terraform_version = Gem::Version.new(version_tag[1..])
  else
    raise "Could not find a GitHub release for Terraform version #{requested_tf_version}"
  end
end

# Build a map of provider source => version constraint
# @type [Hash<String,Hash<String,String>>]
required_providers = json_dig(versions_file_path, %w[terraform required_providers])
# @type [Hash<String, Gem::Requirement>]
provider_constraints = required_providers
                       .transform_keys { |key| canonical_provider_source(required_providers[key]) }
                       .transform_values { |value| Gem::Requirement.new(value["version"]) }

# Build a map of provider source to provider friendly name
# @type [Hash<String, String>]
provider_source_to_name_map = required_providers
                              .transform_values { |value| value["source"] }
                              .invert

# Build a map of provider name => latest version
# @type [Hash<String, Gem::Version>]
provider_latest_versions = provider_constraints.keys.map { |provider_name|
  if provider_name != "auth0/auth0"
    puts "Getting #{provider_name} latest version..."
    [provider_name, latest_provider_version(provider_name)]
  else
    puts "Maintaining auth0/auth0 at #{provider_constraints['auth0/auth0']} because there is an issue preventing us upgrading it"
    puts "See: https://github.com/alphagov/forms-deploy/pull/1142"

    auth0_version = Gem::Version.new(required_providers["auth0"]["version"].sub("= ", "")) # strip any leading "= " in the version requirement
    [provider_name, auth0_version]
  end
}.to_h

# Is latest TF version an upgrade?
_, tf_constraint_ver = Gem::Requirement.parse(current_tf_version_constraint)
tf_upgrade_available = target_terraform_version > tf_constraint_ver

# Are any provider latest versions upgrades?
provider_upgrade_available = provider_constraints.any? do |provider, constraint|
  _, constraint_ver = Gem::Requirement.parse(constraint)
  provider_latest_versions[provider] > constraint_ver
end

# Only check for upgrades if the desired Terraform version is not set
if options[:terraform_version].nil?
  # Stop if there are no upgrades needed (and not forcing)
  # rubocop:disable Style/SoleNestedConditional
  if options[:force] == false
    any_upgrades_available = tf_upgrade_available || provider_upgrade_available
    raise "There are no new versions needed. Stopping." unless any_upgrades_available
  end
  # rubocop:enable Style/SoleNestedConditional
end

# Warn about new major Terraform versions
tf_target_major, = target_terraform_version.canonical_segments
tf_current_major, = tf_constraint_ver.canonical_segments
if tf_target_major != tf_current_major
  puts "WARNING! Terraform major version is going from #{tf_current_major} to #{tf_target_major}. There may be breaking changes"
end

# Warn about new major provider versions
provider_latest_versions.each_key do |provider|
  latest = provider_latest_versions[provider]
  constraint = provider_constraints[provider]
  _, version_in_constraint = Gem::Requirement.parse(constraint)

  latest_major, = latest.canonical_segments
  constraint_major, = version_in_constraint.canonical_segments

  if latest_major > constraint_major
    puts "WARNING! Provider #{provider} major version is going from #{constraint_major} to #{latest_major}. There may be breaking changes"
  end
end

# Write out old version constraints
puts "OLD VERSION CONSTRAINTS"
puts "Terraform: #{current_tf_version_constraint}"
provider_constraints.each_key do |provider|
  puts "#{provider}: #{provider_constraints[provider]}"
end
puts ""

# Write out new version constraints
new_tf_constraint = Gem::Requirement.new("~> #{target_terraform_version}")
new_provider_constraints = provider_latest_versions.transform_values do |version|
  Gem::Requirement.new("~> #{version}")
end

# Set auth0 constraint to be exactly the current version
new_provider_constraints["auth0/auth0"] = Gem::Requirement.new(provider_latest_versions["auth0/auth0"])

puts "NEW VERSION CONSTRAINTS"
puts "Terraform: #{new_tf_constraint}"
new_provider_constraints.each_key do |provider|
  puts "#{provider}: #{new_provider_constraints[provider]}"
end
puts ""

# Update constraints
puts "Writing version constraints to #{versions_file_path}"
set_terraform_version_constraints(versions_file_path, new_tf_constraint, new_provider_constraints, provider_source_to_name_map)

# Install new Terraform version via tfenv
puts "Installing Terraform #{target_terraform_version.segments[0]}.#{target_terraform_version.segments[1]}.x with tfenv"
tfenv "install", "latest:^#{target_terraform_version.segments[0]}.#{target_terraform_version.segments[1]}"
tfenv "use", "latest:^#{target_terraform_version.segments[0]}.#{target_terraform_version.segments[1]}"
# Write latest Terraform version to .terraform-version
terraform_tool_version_file_path = repo_path(".terraform-version")
puts "Writing Terraform version to #{terraform_tool_version_file_path}"
File.write terraform_tool_version_file_path, target_terraform_version

# Update Terraform version in CoedBuild configurations
Dir.glob(repo_path("infra/modules/**/terraform_version.tf.json")).each do |codebuild_vars_file|
  puts "Writing Terraform version to #{codebuild_vars_file}"
  set_codebuild_terraform_version(codebuild_vars_file, target_terraform_version)
end

# Update Terraform version in GitHub Actions
gha_workflow_path = repo_path(".github/workflows/infra-ci.yml")
puts "Writing Terraform version constraint to #{gha_workflow_path}"
set_github_actions_version_constraint(gha_workflow_path, new_tf_constraint)

# Update every Terraform root
terraform_roots = [
  *Dir.glob(repo_path("infra/deployments/deploy/*")).keep_if { |f| File.directory? f },
  *Dir.glob(repo_path("infra/deployments/forms/*")).keep_if { |f| (File.directory? f) && (File.basename(f) != "tfvars") },
  *Dir.glob(repo_path("infra/deployments/integration/*")).keep_if { |f| (File.directory? f) && (File.basename(f) != "tfvars") },
]

tf_plugin_cache_dir = Dir.mktmpdir("tf-plugin-cache")
begin
  puts ""
  puts "The following Terraform roots will be upgraded"
  terraform_roots.each do |root|
    root_path = Pathname.new(root)
    deployments_path = Pathname.new(repo_path("infra/deployments"))
    puts root_path.relative_path_from(deployments_path)
  end
  puts "Beginning Terraform root upgrades. This can take upwards of an hour."

  puts "Plugin cache directory: #{tf_plugin_cache_dir}"
  count = terraform_roots.length
  i = 0
  terraform_roots.each do |root|
    i += 1
    puts ""
    puts "=====[#{i}/#{count}] Upgrading Terraform root: #{root}"
    upgrade_terraform_root(root, tf_plugin_cache_dir)
  end
ensure
  FileUtils.remove_dir tf_plugin_cache_dir
end
