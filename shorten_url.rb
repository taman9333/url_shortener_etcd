# frozen_string_literal: true

require_relative 'url'
require_relative 'counter'
require_relative 'base_n'

class ShortenUrl
  attr_accessor :url, :shortcode

  def self.call(*args, &block)
    new(*args, &block).execute
  end

  def initialize(attrs)
    @url = attrs[:url]
    @shortcode = attrs[:shortcode]
  end

  def execute
    record = if shortcode.nil?
               create_unique_record
             else
               Url.create(url: Url.sanitize(url), shortcode: shortcode)
             end
    if record.valid?
      OpenStruct.new(success?: true, shortcode: record.shortcode, errors: nil)
    else
      OpenStruct.new(success?: false, shortcode: nil, errors: record.errors)
    end
  end

  private

  def create_unique_record
    unique_shortcode = BaseN.encode(Counter.increment)
    Url.create(url: Url.sanitize(url), shortcode: unique_shortcode)
  # We still need to rescue as generated short code might made collision with
  # Desired shortcode that user used before
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
