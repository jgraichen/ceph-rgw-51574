#!/usr/bin/env ruby
# frozen_string_literal: true

require 'aws-sdk-s3'
require 'logger'
require 'base64'
require 'yaml'
require 'json'

# Ensure errors are printed
$stdout.sync = $stderr.sync = true

client = Aws::S3::Client.new(
  endpoint: 'http://127.0.0.1:8080',
  force_path_style: true,
  region: 'default',
  access_key_id: 'admin',
  secret_access_key: 'admin',
  http_wire_trace: true,
  logger: Logger.new($stdout)
)

res = Aws::S3::Resource.new(client: client)

bucket = res.bucket('test')
bucket.create
bucket.policy.put(policy: JSON.generate(YAML.safe_load(File.read('policy.yml'))))

signed = bucket.presigned_post(
  {
    key_starts_with: 'uploads/',
    acl: 'public-read',
    metadata: { 'x-purpose': 'user-upload', 'x-state': 'accepted' },
    allow_any: ['Content-Type']
  }
)

pp JSON.parse(Base64.decode64(signed.fields['policy']))

# Wait a bit to clearly have a new request in the log
sleep 1

uri = URI(signed.url)
form_data = signed.fields.to_a
form_data << ['key', 'uploads/test.txt']
form_data << ['file', 'DEMO TEXT']
form_data << ['Content-Type', 'plain/text']

request = Net::HTTP::Post.new(uri)
request.set_form(form_data, 'multipart/form-data')

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
  http.request(request)
end

puts
puts 'Got a response:'
puts
pp response
