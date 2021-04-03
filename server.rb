# frozen_string_literal: true

require 'sinatra'
require 'json'
require_relative 'shorten_url'

before do
  content_type 'application/json'
end

before '/shorten' do
  begin
    valid_params = %w[url shortcode]
    req_body = request.body.read
    permitted = JSON.parse(req_body).select { |k, _v| valid_params.include? k }
    @job_params = Sinatra::IndifferentHash[permitted]
  rescue JSON::ParserError
    halt 400, { message: 'Invalid JSON' }.to_json
  end
end

get '/:shortcode' do
  record = Url.find_by_shortcode(params[:shortcode])
  if record.present?
    # use atomic update as locking taking more time & avoid locking problems
    Url.where(id: record.id).update_all("redirect_count = redirect_count + '1',
                               last_seen_date = '#{Time.now.to_s(:db)}'")
    [302, { 'location' => record.url }, {}]
  else
    [404, { error: 'The shortcode cannot be found in the system' }.to_json]
  end
end

post '/shorten' do
  result = ShortenUrl.call(@job_params)
  if result.success?
    [201, { shortcode: result.shortcode }.to_json]
  elsif result.errors.added? :shortcode, 'has already been taken'
    [409, { errors: result.errors.full_messages }.to_json]
  elsif result.errors.added? :url, :blank
    [400, { errors: result.errors.full_messages }.to_json]
  else
    [422, { errors: result.errors.full_messages }.to_json]
  end
end

get '/:shortcode/stats' do
  record = Url.find_by_shortcode(params[:shortcode])
  if record.present?
    [200, { startDate: record.created_at.iso8601,
            redirectCount: record.redirect_count,
            lastSeenDate: record.last_seen_date&.iso8601 }.to_json]
  else
    [404, { error: 'The shortcode cannot be found in the system' }.to_json]
  end
end
