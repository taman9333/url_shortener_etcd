# frozen_string_literal: true

source 'https://rubygems.org'

gem 'pg'
gem 'rake' # to run rake tasks
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'thin'
gem 'etcdv3'

group :development do
  # reload sinatra app on changes
  gem 'rerun'
end

group :test, :development do
  gem 'byebug'
  gem 'rubocop', require: false
end

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'shoulda-matchers'
end
