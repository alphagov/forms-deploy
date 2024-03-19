require "aws-sdk-codepipeline"

class LiveAWSSDKFactory
  # @return [Aws::CodePipeline::Client]
  # @param [string] role_arn
  def self.new_code_pipeline(role_arn)
    Aws::CodePipeline::Client.new(
      credentials: Aws::AssumeRoleCredentials.new(
        role_arn: role_arn,
        role_session_name: "govuk_forms_codepipeline_visualiser",
        region: "eu-west-2"
      ),
      region: "eu-west-2"
    )
  end
end