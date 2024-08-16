require 'json'
require 'aws-sdk-codepipeline'
require 'logger'
require 'spec_helper'

require_relative '../invoke.rb'

describe Invoke do
  let(:codepipeline_client) { instance_double(Aws::CodePipeline::Client) }
  let(:pipeline_name) { 'PIPELINE_TO_INVOKE' }
  let(:container_image_uri) { 'CONTAINER_IMAGE_URI' }
  let(:event) do
    {
      'client_request_token' => 'some_token',
      'name' => pipeline_name,
      'variables' => [
        {
          'name' => 'container_image_uri',
          'value' => container_image_uri
        }
      ],
      'sourceRevisions' => [
        {
          'actionName' => 'actionName',
          'revisionType' => 'revisionType',
          'revisionValue' => 'revisionValue'
        }
      ]
    }
  end

  before do
    allow(Aws::CodePipeline::Client).to receive(:new).and_return(codepipeline_client)
  end

  describe '#main' do
    it 'invokes the AWS CodePipeline API' do
        expect(codepipeline_client).to receive(:start_pipeline_execution)

        Invoke.main(event: event, context: double('context'))
    end

    it 'invokes the AWS CodePipeline API with correct parameters' do
        expected_params = {
          client_request_token: 'some_token',
          name: pipeline_name,
          source_revisions: [
            {
              action_name: 'actionName',
              revision_type: 'revisionType',
              revision_value: 'revisionValue'
            }
          ],
          variables: [
            {
              name: 'container_image_uri',
              value: container_image_uri
            }
          ]
        }

        expect(codepipeline_client).to receive(:start_pipeline_execution).with(expected_params)

        Invoke.main(event: event, context: double('context'))
    end
  end
end