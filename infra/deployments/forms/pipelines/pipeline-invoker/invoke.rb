require 'logger'
require 'json'
require 'aws-sdk-codepipeline'

# Expecting event to take this form
# {
#   "name": "PIPELINE_TO_INVOKE",
#   "variables": [
#       {
#           "name": "container_image_uri",
#           "value": "CONTAINER_IMAGE_URI"
#       }
#   ]
# }
#
# It should be a valid codepipeline:StartPipelineExecution payload

def main(event:, context:)
    logger = Logger.new($stdout)
    log_payload = Hash.new
    log_payload["event_received"] = event
    
    payload = {}
    payload["name"] = event["name"]
    
    if event["variables"] != nil then
        payload["variables"] = []
        event["variables"].each do |var|
            payload["variables"] << {
                name: var["name"],
                value: var["value"]
            } 
        end
    else
        payload["variables"] = []        
    end
    
    if event["sourceRevisions"] != nil then
        payload["source_revisions"] = []
        event["sourceRevisions"].each do |revision|
            payload["source_revisions"] << {
                action_name: revision["actionName"],
                revision_type: revision["revisionType"],
                revision_value: revision["revisionValue"]
            } 
        end
    else
        payload["source_revisions"] = []
    end
    
    payload["client_request_token"] = event["client_request_token"]#
    
    log_payload["api_payload"] = payload
    logger.info(log_payload.to_json)
    
    client = Aws::CodePipeline::Client.new(region: 'eu-west-2')
    client.start_pipeline_execution(
        name: payload["name"],
        variables: payload["variables"],
        source_revisions: payload["source_revisions"],
        client_request_token: payload["client_request_token"]
    )
end