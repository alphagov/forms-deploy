require 'colorize'
require 'uri'
require 'net/http'
require 'json'

ENVIRONMENTS = {
  'dev': {
    aws: 'api.dev.forms.service.gov.uk',
    paas: 'forms-api-dev.london.cloudapps.digital'
  },
  'staging': {
    aws: 'api.stage.forms.service.gov.uk',
    paas: 'forms-api-staging.london.cloudapps.digital'
  },
  'production': {
    aws: 'api.prod-temp.forms.service.gov.uk',
    paas: 'forms-api-production.london.cloudapps.digital'
  }
}.freeze

$environment = ARGV[0]
$aws_key = ARGV[1]
$paas_key = ARGV[2]

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

  JSON.parse(res.body.gsub('\r', ''))
end

def list_forms(host_name, auth_key)
  uri = URI("https://#{host_name}/api/v1/forms")
  forms_api_request(uri, auth_key)
end

def get_live_version(host_name, auth_key, form_id)
  uri = URI("https://#{host_name}/api/v1/forms/#{form_id}/live")
  forms_api_request(uri, auth_key)
end

def get_draft_version(host_name, auth_key, form_id)
  uri = URI("https://#{host_name}/api/v1/forms/#{form_id}/draft")
  forms_api_request(uri, auth_key)
end

def select_form_by_id(id, forms)
  forms.select do |form|
    form['id'] == id
  end
end

def compare_single_form(aws_form, paas_form, form_type)
  differences = {}
  id = paas_form['id']
  paas_form.each do |key, value|
    if aws_form[key] != value
      differences[key] = {
        aws: aws_form[key],
        paas: value
      }
    end
  end
  if differences.size > 0
    puts "Form #{id} (#{form_type}) differences:".red
    puts JSON.pretty_generate(differences)
  else
    puts "Form #{id} (#{form_type}) is ok".green.bold
  end
end

def compare_forms(aws_forms, paas_forms)
  paas_forms.each do |paas_form|
    id = paas_form['id']
    aws_form = select_form_by_id(id, aws_forms)[0]
    if aws_form.nil?
      puts "Form #{id} is not in AWS".red.bold
    else
      compare_single_form(aws_form, paas_form, 'base')

      if paas_form['has_live_version']
        paas_live_version = get_live_version(ENVIRONMENTS[$environment.to_sym][:paas], $paas_key, id)
        aws_live_version = get_live_version(ENVIRONMENTS[$environment.to_sym][:aws], $aws_key, id)
        compare_single_form(aws_live_version, paas_live_version, 'live')
      end

      if paas_form['has_draft_version']
        paas_draft_version = get_draft_version(ENVIRONMENTS[$environment.to_sym][:paas], $paas_key, id)
        aws_draft_version = get_draft_version(ENVIRONMENTS[$environment.to_sym][:aws], $aws_key, id)
        compare_single_form(aws_draft_version, paas_draft_version, 'draft')
      end
    end
  end
end

unless ENVIRONMENTS.key?($environment.to_sym)
  puts "Unknown environment '#{$environment}'".red.bold
  usage
end

usage if !$aws_key || $aws_key.empty?
usage if !$paas_key || $aws_key.empty?

puts "Checking parity of #{$environment} forms".green
aws_forms = list_forms(ENVIRONMENTS[$environment.to_sym][:aws], $aws_key)
paas_forms = list_forms(ENVIRONMENTS[$environment.to_sym][:paas], $paas_key)
compare_forms(aws_forms, paas_forms)

