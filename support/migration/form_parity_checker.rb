require 'colorize'
require 'uri'
require 'net/http'
require 'json'

ENVIRONMENTS = {
  'development': {
    aws: 'api.dev.forms.service.gov.uk',
    paas: 'forms-api-dev.london.cloudapps.digital'
  },
  'staging': {},
  'production': {}
}.freeze

environment = ARGV[0]
aws_key = ARGV[1]
paas_key = ARGV[2]

def usage
  puts "#{$PROGRAM_NAME} <environment> <aws-key> <paas-key>".red.bold
  exit 1
end

def forms_api_request(uri, auth_key)
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "Token #{auth_key}"
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(req)
  end

  unless res.is_a? Net::HTTPSuccess
    puts "ERROR: #{res}".red.bold
    exit 1
  end

  JSON.parse(res.body)
end

def list_forms(host_name, auth_key)
  uri = URI("https://#{host_name}/api/v1/forms")
  forms_api_request(uri, auth_key)
end

def extract_form_names(forms)
  forms.each_with_object([]) do |form, names|
    names.push(form['name'])
  end
end

def compare_forms(aws_forms, paas_forms)
  total_forms = Hash.new do |hash, key|
    hash[key] = {
      aws: false,
      paas: false
    }
  end

  aws_forms.each do |form|
    total_forms[form['name']][:aws] = true
  end

  paas_forms.each do |form|
    total_forms[form['name']][:paas] = true
  end
  total_forms
end

unless ENVIRONMENTS.key?(environment.to_sym)
  puts "Unknown environment '#{environment}'".red.bold
  usage
end

usage if !aws_key || aws_key.empty?
usage if !paas_key || aws_key.empty?

puts "Checking parity of #{environment} forms".green
aws_forms = list_forms(ENVIRONMENTS[environment.to_sym][:aws], aws_key)
paas_forms = list_forms(ENVIRONMENTS[environment.to_sym][:paas], paas_key)

results = compare_forms(aws_forms, paas_forms)
results.each do | form_name, result |
  puts "#{form_name} paas:#{result[:paas]} aws:#{result[:aws]}"
end


