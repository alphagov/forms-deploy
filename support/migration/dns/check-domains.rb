# frozen_string_literal: true

require 'resolv'
require 'aws-sdk-cloudfront'
require 'aws-sdk-elasticloadbalancingv2'
require 'colorize'
require 'aws-sdk-sts'

# Script for checking if the domain names used for an environment resolve to
# PaaS or AWS CloudFront distributions. Run in an authenticated shell for the
# environment to be checked, e.g.
# aws-vault exec staging-support -- ruby check-domains.rb

DOMAIN_NAMES = {
  staging: {
    tmp_domains: {
      admin: 'admin.stage.forms.service.gov.uk',
      runner: 'submit.stage.forms.service.gov.uk',
      api: 'api.stage.forms.service.gov.uk'
    },
    permanent_domains: {
      admin: 'admin.staging.forms.service.gov.uk',
      runner: 'submit.staging.forms.service.gov.uk',
      api: 'api.staging.forms.service.gov.uk'
    },
    paas_only_domains: {
      api: 'forms-api-staging.london.cloudapps.digital'
    }
  },
  production: {
    tmp_domains: {
      admin: 'admin.prod-temp.forms.service.gov.uk',
      runner: 'submit.prod-temp.forms.service.gov.uk',
      api: 'api.prod-temp.forms.service.gov.uk'
    },
    permanent_domains: {
      admin: 'admin.forms.service.gov.uk',
      runner: 'submit.forms.service.gov.uk',
      api: 'api.forms.service.gov.uk'
    },
    paas_only_domains: {
      api: 'forms-api-prod.london.cloudapps.digital'
    }
  }
}.freeze

def fetch_environment
  sts = Aws::STS::Client.new
  account = sts.get_caller_identity({}).account
  { '498160065950' => :development,
    '972536609845' => :staging,
    '443944947292' => :production,
    '619109835131' => :user_research }[account]
end

def get_ipv4_addresses(domain)
  ips = Resolv.getaddresses(domain)
  ips.select do |ip|
    ip[/\d+\./]
  end
end

def get_cloudfront_ip
  cloudfront_client = Aws::CloudFront::Client.new({
                                                    region: 'eu-west-2'
                                                  })
  cloudfront_distribution = cloudfront_client.list_distributions[0].items[0]
  domain_name = cloudfront_distribution[:domain_name]
  get_ipv4_addresses domain_name
end

def get_alb_ip
  alb_client = Aws::ElasticLoadBalancingV2::Client.new({
                                                    region: 'eu-west-2'
                                                  })
  dns_name = alb_client.describe_load_balancers[:load_balancers][0][:dns_name]
  get_ipv4_addresses dns_name
end

def summarise_domain(aws_cloudfront_ip_address, domains)
  domains.each do |domain|
    puts "#{domain}"
    ip_addresses = get_ipv4_addresses domain
    if ip_addresses.empty?
      puts 'No records'.bold.red
      break
    end

    ip_addresses.each do |ip|
      if aws_cloudfront_ip_address.include?(ip)
        puts "#{ip} aws".green
      else
        puts "#{ip} paas".blue
      end
    end
  end
end

def check_product_pages
  uri = URI('https://www.forms.service.gov.uk')
  res = Net::HTTP.get_response(uri)
  if res.is_a?(Net::HTTPSuccess)
    puts 'OK'.green
  else
    puts 'FAILED TO GET PRODUCT PAGES'.red
  end
end

def check_environment
  environment = fetch_environment
  puts "Checking DNS in #{environment}"
  alb_ip_addresses = get_alb_ip

  puts "\nThese domains are the permanent domains and should point to AWS when the migration is complete".bold
  permanent_domains = DOMAIN_NAMES[environment.to_sym][:permanent_domains].values
  summarise_domain(alb_ip_addresses, permanent_domains)

  puts "\nThese are temporary domains and should only point to AWS".bold
  tmp_domains = DOMAIN_NAMES[environment.to_sym][:tmp_domains].values
  summarise_domain(alb_ip_addresses, tmp_domains)

  puts "\nForms-runner and Froms-admin on PaaS use CF domain for forms-api. This will stay with PaaS".bold
  paas_only_domains = DOMAIN_NAMES[environment.to_sym][:paas_only_domains].values
  summarise_domain(alb_ip_addresses, paas_only_domains)

  if environment == :production
    puts "\nChecking product pages are available".bold
    check_product_pages
  end
end

check_environment
