# frozen_string_literal: true

require "commands/notify"
require "notifications/client"

describe Notify do
  context "without API key provided" do
    it "outputs that the key must be provided" do
      expect { described_class.new.run }
        .to output(/key must be provided/).to_stdout
    end
  end

  context "with an API key provided" do
    let(:notify_mock) do
      notify_mock = instance_double(Notifications::Client)

      allow(notify_mock).to receive_messages(
        get_notifications: Notifications::Client::NotificationsCollection.new({
          links: [],
          "notifications" => [],
        }),
        get_notification: Notifications::Client::Notification.new({}),
      )

      notify_mock
    end

    before do
      allow(Notifications::Client)
        .to receive(:new)
        .and_return(notify_mock)
    end

    it "-k, --key, passes the api key" do
      stub_const("ARGV", ["-k", "some-key"])
      described_class.new.run

      expect(Notifications::Client)
        .to have_received(:new)
        .with("some-key")
    end

    it "queries all recent records by default" do
      stub_const("ARGV", ["-k", "some-key"])
      described_class.new.run

      expect(notify_mock)
        .to have_received(:get_notifications)
    end

    it "-n, --notification, queries for a single notification" do
      expected_id = "123"

      stub_const("ARGV", ["-k", "some-key", "-n", expected_id])
      described_class.new.run

      expect(notify_mock)
        .to have_received(:get_notification)
        .with(expected_id)
    end
  end
end
