require 'notifications/client'
require "debug"

class NotifyService
  def initialize
    @notify_api_key = ENV["SETTINGS__GOVUK_NOTIFY__API_KEY"]
  end

  def get_submission_email(notification_id)
    if @notify_api_key.nil? || @notify_api_key.empty?
      puts "Warning: no NOTIFY_API_KEY set."
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    notify_results = client.get_notification(notification_id)
    notify_results
  end

  def get_submission_emails()
    if @notify_api_key.nil? || @notify_api_key.empty?
      puts "Warning: no NOTIFY_API_KEY set."
      return nil
    end

    client = Notifications::Client.new(@notify_api_key)
    client.get_notifications().collection
  end
end

client = NotifyService.new
puts pp client.get_submission_email("77b01c67-2ddc-451e-9095-9968f25264bf")
# puts client.get_submission_emails
