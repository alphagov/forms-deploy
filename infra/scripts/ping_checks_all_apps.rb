# This script checks if our services are running by requesting the following
# admin, submit, api urls in the dev and staging environments.

require "net/http"

environment = %w[dev stage]
apps = %w[admin submit api]

environment.each do |environment|
  apps.each do |apps|
    uri = "https://#{apps}.#{environment}.forms.service.gov.uk/ping"
    res = Net::HTTP.get_response(URI(uri))
    if res.is_a?(Net::HTTPSuccess)
      puts "#{apps} #{environment} OK"
    else
      puts "#{apps} #{environment} Status Code: #{res.code} Error: #{res.message}"
    end
  end
end
