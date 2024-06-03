require "aws-sdk-sns"

class Notifier
  # @!attribute [r] sns_client
  #   @return [Aws::SNS::Client]
  # @!attribute [r] topic_arn
  #   @return [string]
  # @!attribute [r] aws_account_name
  #   @return [string]
  attr_reader :sns_client, :topic_arn, :aws_account_name

  # @param [Aws::SNS::Client] sns_client
  # @param [string] topic_arn
  # @param [string] aws_account_name
  def initialize(sns_client, topic_arn, aws_account_name)
    @sns_client = sns_client
    @topic_arn = topic_arn
    @aws_account_name = aws_account_name
  end

  # @param [string] pipeline
  # @param [Time] paused_since
  # @param [string] paused_reason
  def notify_about_paused_pipeline(pipeline, paused_since, paused_reason)
    alert_body = <<~BODY
      Pipeline #{pipeline} has been paused since #{paused_since}. We probably meant to unpause it.

      The reason given for pausing the pipeline was:

      #{paused_reason}
    BODY
    gds_cli_role = case @aws_account_name
                   when "production" then "forms-prod-support"
                   when "development" then "forms-dev-support"
                   else "forms-#{@aws_account_name}-support"
                   end

    console_url = "https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/#{CGI.escapeURIComponent(pipeline)}/view?region=eu-west-2"
    gds_cli_command = "gds aws #{gds_cli_role} --open \"#{console_url}\""
    msg = {
      "version" => "1.0",
      "source" => "custom",
      "content" => {
        "textType" => "client-markdown",
        "title" => ":double_vertical_bar: Pipeline paused: #{pipeline}",
        "description" => alert_body,
        "nextSteps" => [
          "Log into the #{@aws_account_name} account",
          "Open the pipeline in AWS CodePipeline and enable any paused stage transitions",
          "Use the command below to login and open the console at the pipeline screen",
          gds_cli_command,
        ],
      },
    }
    @sns_client.publish(
      topic_arn: @topic_arn,
      message: JSON.dump(msg),
    )
  end
end
