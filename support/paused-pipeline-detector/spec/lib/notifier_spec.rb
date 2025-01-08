require "aws-sdk-sns"
require "json"

require_relative "../../lib/notifier"

describe Notifier do
  subject(:notifier) do
    described_class.new(sns_client, topic_arn, "aws_account_name")
  end

  let(:sns_client) do
    instance_double(Aws::SNS::Client)
  end

  let(:topic_arn) do
    "arn:aws:sns:topic/testing"
  end

  it "sends valid Slack notification payloads to the SNS topic" do
    expect(sns_client).to receive(:publish) do |payload|
      expect(payload[:topic_arn]).to be topic_arn

      expect(payload[:message]).not_to be_nil
      expect { JSON.parse(payload[:message]) }.not_to raise_error, "Message was not valid JSON"

      msg_hash = JSON.parse(payload[:message])
      expect(msg_hash).to include(
        "version" => "1.0",
        "source" => "custom",
      )
      expect(msg_hash["content"]).to include(
        "textType" => "client-markdown",
      )

      expect(msg_hash["content"]).to have_key("title")
      expect(msg_hash["content"]).to have_key("description")
      expect(msg_hash["content"]).to have_key("nextSteps")
    end

    notifier.notify_about_paused_pipeline("pipeline_a", Time.at(Time.now.to_i - (60 * 60 * 36)), "Testing pauses")
  end
end
