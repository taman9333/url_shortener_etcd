# frozen_string_literal: true

require 'sinatra/activerecord'

class Url < ActiveRecord::Base
  CHARSETS = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a + ['_']
  URL_REGEX = %r/
                ^(((https?):\/\/|)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}
                (:[0-9]{1,5})?(\/.*)?)$
              /x.freeze

  validates :url, presence: true, format: { with: URL_REGEX }

  validates :shortcode, presence: true, uniqueness: true,
                        format: { with: /\A[0-9a-zA-Z_]{4,}\z/ }

  # update counter with locking record to handle race condition
  def update_count!
    with_lock do
      self.redirect_count += 1
      self.last_seen_date = Time.now
      save!
    end
  end

  def self.generate_unique_shortcode
    unique_shortcode = nil
    loop do
      unique_shortcode = 6.times.map { CHARSETS.sample }.join
      break if Url.find_by_shortcode(unique_shortcode).nil?
    end
    unique_shortcode
  end

  def self.sanitize(original_url)
    return if original_url.nil?

    url_dup = original_url.dup
    url_dup.strip!
    url_dup = url_dup.downcase.gsub(%r{(https?:\/\/)|(www\.)}, '')
    url_dup.slice!(-1) if url_dup[-1] == '/'
    "http://#{url_dup}"
  end
end
