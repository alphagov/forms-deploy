## GOV.UK Forms Support

### Introduction

This 'support' directory contains information and scripts for assisting with support queries and incidents.

### How to query the Notify API

You'll need to obtain a Notify API key and set it in the `SETTINGS__GOVUK_NOTIFY__API_KEY` environment variable. note that the permissions your key has will affect what you can query - ideally you'll need a live key to query live emails.
this script contains two methods - one for querying an individual message with a known ID, and one for obtaining the last 250 emails sent. To use this:

1. Install the dependencies

```zsh
bundle install
```

2. Edit the bottom of `scripts/query_notify_api.rb` to do what you need it to, e.g.:

```ruby
# Initialise
client = NotifyService.new

# query a single script
puts pp client.get_submission_email("77b01c67-2ddc-451e-9095-9968f25264bf")

# query the last 250 messages, filter them, and format the response
puts client.get_submission_emails
    .filter{|message| message.email_address == "example@example.gov.uk"}
    .map{|message| "id: #{message.id}"}
```

3. Run the script in your console:

```zsh
ruby scripts/query_notify_api.rb
```

See the [Notify Ruby API documentation] (https://docs.notifications.service.gov.uk/ruby.html#get-message-status) for more information.
