# This script checks if our services are running by requesting the following
# admin, submit urls in the dev and staging environments.

require "net/http"

environments = %w[dev stage]
apps = %w[admin submit]

environments.each do |environment|
  apps.each do |app|
    uri = "https://#{app}.#{environment}.forms.service.gov.uk/up"
    res = Net::HTTP.get_response(URI(uri))
    if res.is_a?(Net::HTTPSuccess)
      puts "#{app} #{environment} OK"
    else
      puts "#{app} #{environment} Status Code: #{res.code} Error: #{res.message}"
    end
  end
end
