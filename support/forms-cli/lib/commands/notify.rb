# frozen_string_literal: true

require 'notifications/client'
require 'colorize'
require 'json'

# Queries GOV.UK Notify for one or more notifications
class Notify
  def run
    @options = {}
    parse_options
    return unless valid_options?

    @notify = Notifications::Client.new(@options[:key])

    if @options[:notification_id]
      puts JSON.pretty_generate(notification)
    else
      puts JSON.pretty_generate(recent_notifications)
    end
  end

  private

  def valid_options?
    if @options[:key].nil?
      puts '-k, --key must be provided'.red
      return false
    end

    true
  end

  def notification
    extract_details @notify.get_notification(@options[:notification_id])
  end

  def recent_notifications
    @notify
      .get_notifications
      .collection
      .map(&method(:extract_details))
  end

  def extract_details(response)
    {
      id: response.id,
      status: response.status,
      template: response.template,
      body: response.body,
      subject: response.subject
    }
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "
      Queries GOV.UK Notify to return submitted email details. If a
      notification id [-n, --notification] is not provided it will return up
      to 250 notifications of the most recent notifications within the previous
      7 days.

      Example:
      forms notify -k <API_KEY>\n\n"

      opts.on('-h', '--help', 'Prints help') do
        puts opts
        exit
      end

      opts.on('-kKEY', '--key=KEY', '[Mandatory] The GOV.UK Notify API Key') do |key|
        @options[:key] = key
      end

      opts.on('-nId', '--notification=Id', 'Id of notification to return') do |id|
        @options[:notification_id] = id
      end
    end.parse!
  end
end
