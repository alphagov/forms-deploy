require "activesupport-duration-human_string"
require "json"
require "ostruct"
require "sinatra"
require "yaml"

require_relative "./background_pipeline_status_updates"

require_relative "lib/aws-sdk-factory/live"
require_relative "lib/aws-sdk-factory/development"

require_relative "lib/views/all_pipelines"
require_relative "lib/views/group"

set :public_folder, "public"
helpers do
  def slugify(str)
    str.downcase
              .gsub(/[ _:\/]/, "-")
  end

  def active_page_css_class?(path)
    request.path_info == path ? "govuk-header__navigation-item--active" : ""
  end
end

is_dev_mode = ENV.fetch("PIPELINE_VISUALISER_DEV_MODE", false)

config = YAML.safe_load_file("./config.yml")

aws_clients = []
config["roles"].each do |role|
  aws_clients << if is_dev_mode
                   {
                     "client" => DevelopmentAWSSDKFactory.new_code_pipeline(role["role"]),
                     "gds_cli_role" => role["gds_cli_role"],
                   }
                 else
                   {
                     "client" => LiveAWSSDKFactory.new_code_pipeline(role["role"]),
                     "gds_cli_role" => role["gds_cli_role"],
                   }
                 end
end

pipelines_map = start_background_pipeline_status_updater(aws_clients)

get "/" do
  groups = []
  config["groups"].each_key do |k|
    group_elements = config["groups"][k]
    group_pipelines = group_elements
                      .map { |name| pipelines_map.fetch(name, nil) }
                      .reject(&:nil?)
    group = PipelineGroup.new(k, group_pipelines)
    groups << group
  end

  view = AllPipelinesView.new(groups)
  erb :index, locals: { view:, is_dev_mode: }
end

get "/deploying-changes" do
  erb :deploying_changes
end

get "/group/:group_slug" do
  all_groups = config["groups"].to_a
  group = all_groups.find { |grp| params["group_slug"] == slugify(grp[0]) }
  pass if group.nil?

  pipeline_names = group[1]
  pipelines = pipeline_names
              .map { |name| pipelines_map.fetch(name, nil) }
              .reject(&:nil?)

  erb :group, locals: {
    view: Group.new(group[0], pipelines),
    is_dev_mode:,
    breadcrumbs: {
      "Home" => "/",
    },
  }
end

get "/group/:group_slug/pipeline/:pipeline_slug" do
  all_groups = config["groups"].to_a
  group_slugs_to_names = config["groups"].keys.map { |name| [slugify(name), name] }.to_h
  group = all_groups.find { |grp| params["group_slug"] == slugify(grp[0]) }
  pass if group.nil?

  pipeline_slugs_to_names = group[1].map { |name| [slugify(name), name] }.to_h
  pass unless pipeline_slugs_to_names.keys.include? params["pipeline_slug"]

  group_name = group_slugs_to_names[params["group_slug"]]
  pipeline_name = pipeline_slugs_to_names[params["pipeline_slug"]]
  pipeline = pipelines_map[pipeline_name]

  erb :pipeline, locals: {
    pipeline:,
    is_dev_mode:,
    breadcrumbs: {
      "Home" => "/",
      group_name => "/group/#{params['group_slug']}",
    },
  }
end

not_found do
  erb :not_found
end
