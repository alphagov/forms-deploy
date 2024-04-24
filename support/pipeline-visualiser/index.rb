require 'activesupport-duration-human_string'
require "json"
require "ostruct"
require "sinatra"
require "yaml"

require_relative "./background_pipeline_status_updates"

require_relative "lib/aws-sdk-factory/live"
require_relative "lib/aws-sdk-factory/development"

require_relative "lib/views/AllPipelines"

set :public_folder, "public"
helpers do
  def slugify(str)
    return str.downcase
              .gsub(/[ _:\/]/, "-")
  end

  def active_page_css_class?(path)
    request.path_info == path ? "govuk-header__navigation-item--active" : ""
  end
end

is_dev_mode = ENV.fetch("PIPELINE_VISUALISER_DEV_MODE", false)

config = YAML::safe_load_file("./config.yml")
aws_clients = []
config["roles"].each do |role|
  if is_dev_mode
    aws_clients << {
      "client" => DevelopmentAWSSDKFactory.new_code_pipeline(role["role"]),
      "gds_cli_role" => role["gds_cli_role"]
    }
  else
    aws_clients << {
      "client" => LiveAWSSDKFactory.new_code_pipeline(role["role"]),
      "gds_cli_role" => role["gds_cli_role"]
    }
  end
end

pipelines_map = start_background_pipeline_status_updater(aws_clients)

get "/" do
  groups = []
  config["groups"].each do |k, _|
    group_elements = config["groups"][k]
    group_pipelines = []
    group_elements.map do |elem|
      if pipelines_map.fetch(elem, nil) != nil
        p = pipelines_map[elem]
        group_pipelines << p
      end
    end
    group = PipelineGroup.new(k, group_pipelines)
    groups << group
  end

  view = AllPipelinesView.new(groups)
  erb :index, :locals => { :view => view, :is_dev_mode => is_dev_mode }
end

get "/deploying-changes" do
  erb :deploying_changes
end
