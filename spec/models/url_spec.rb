# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../url'

RSpec.describe Url, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:shortcode) }
    it { should validate_uniqueness_of(:shortcode) }
  end

  describe 'Url class methods' do
    context 'generate_unique_shortcode' do
      it 'should be unique shortcode that is not in the db & match the regex' do
        shortcode = Url.generate_unique_shortcode
        expect(Url.find_by_shortcode(shortcode)).to be_nil
        expect(shortcode).to match(/\A[0-9a-zA-Z_]{4,}\z/i)
      end
    end

    context 'sanitize url' do
      it 'should sanitize url to make sure we won\'t have same urls' do
        url = '   https://www.test.com/'
        sanitized_url = Url.sanitize(url)
        expect(sanitized_url).to eq('http://test.com')
      end
    end
  end

  context 'update_count! instance method' do
    it 'should update redirect count of record & update last seen date' do
      url = Url.create(url: 'http://test1.com',
                       shortcode: Url.generate_unique_shortcode)
      url.update_count!
      expect(url.redirect_count).to eq(1)
    end
  end
end
