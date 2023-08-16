# frozen_string_literal: true

require "aws-sdk-cloudwatchlogs"

require "debug"

class CloudWatchFollow
  def initialize(env, app, task_arn: nil)
    @env = env
    @app = app
    @task_arn = task_arn

    @cloudwatch_api = Aws::CloudWatchLogs::Client.new
  end

  def follow_log_events(start_time = nil)
    start_time ||= Time.now
    start_epoch_ms = (start_time.to_r * 1000).to_i

    if log_stream_name
      puts "Following log stream #{log_stream_name} in log group #{log_group_name}..."
    else
      puts "Following log streams for app forms-#{app} in log group #{log_group_name}..."
    end

    Enumerator.new do |enum|
      loop do
        parameters = filter_log_events_parameters
          .merge(start_time: start_epoch_ms + 1)
        response = cloudwatch_api.filter_log_events(parameters)

        response.each do |page|
          page.events.each do |event|
            start_epoch_ms = event.timestamp if event.timestamp > start_epoch_ms
          end
          enum.yield page.events
        end
      rescue Aws::CloudWatchLogs::Errors::ResourceNotFoundException
        # try waiting until log stream exists
        yield []
      end
    end
  end

private

  attr_reader :env, :app, :task_arn, :cloudwatch_api

  def task_arn_id
    task_arn.split("/").last if task_arn
  end

  def log_group_name
    "forms-#{app}-#{env}"
  end

  def log_stream_name
    "#{log_stream_name_prefix}/#{task_arn_id}" if task_arn
  end

  def log_stream_name_prefix
    "#{log_group_name}/forms-#{app}"
  end

  def filter_log_events_parameters
    {
      log_group_name:,
      log_stream_names: log_stream_name ? [log_stream_name] : nil,
      log_stream_name_prefix: log_stream_name ? nil : log_stream_name_prefix,
    }
  end
end
