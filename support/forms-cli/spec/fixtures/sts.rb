# frozen_string_literal: true

require 'time'

# Fixtures for STS api calls
module StsFixtures
  @sts_client_stub = Aws::STS::Client.new({ stub_responses: true })

  def self.get_caller_identity
    @sts_client_stub.stub_data(:get_caller_identity, { account: '498160065950' })
  end
end
