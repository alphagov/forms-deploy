# frozen_string_literal: true

require "utilities/helpers"

describe Helpers do
  describe ".aws_authenticated?" do
    let(:dummy_class) { Class.new { include Helpers } }

    context "when not authenticated" do
      it "returns false" do
        expect(dummy_class.new.aws_authenticated?).to be false
      end

      it "prints warning to stdout" do
        expect { dummy_class.new.aws_authenticated? }.to output(/You must be authenticated/).to_stdout
      end
    end

    context "when authenticated" do
      it "returns true" do
        stub_const("ENV",
                   {
                     "AWS_ACCESS_KEY_ID" => "test_key_id",
                     "AWS_REGION" => "test_region",
                     "AWS_SESSION_TOKEN" => "test_token",
                     "AWS_SECRET_ACCESS_KEY" => "test_secret_key",
                   })
        expect(dummy_class.new.aws_authenticated?).to be true
      end
    end
  end
end
