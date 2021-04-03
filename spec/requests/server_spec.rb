# frozen_string_literal: true

require_relative '../spec_helper'
require 'rack/test'
require_relative '../../server'

RSpec.describe 'Url', type: :request do
  include Rack::Test::Methods
  let(:params) do
    { url: 'http://test333.com', shortcode: Url.generate_unique_shortcode }
  end
  let(:content_type) { 'application/json' }
  let(:request) { post '/shorten', params.to_json, CONTENT_TYPE: content_type }

  # Create Url test suite
  describe 'POST /shorten' do
    context 'valid request without shortcode' do
      before do
        post '/shorten', params.except(:shortcode).to_json,
             CONTENT_TYPE: content_type
      end

      it 'returns 201 status code' do
        expect(last_response.status).to eq(201)
      end

      it 'returns shortcode as response that matches specific regex' do
        response = JSON.parse(last_response.body)
        expect(response.keys).to match_array(['shortcode'])
        expect(response['shortcode']).to match(/\A[0-9a-zA-Z_]{6}\z/i)
      end
    end

    context 'valid request with specific shortcode' do
      it 'return 201 status code if shortcode match regex' do
        request
        expect(last_response.status).to eq(201)
      end
    end

    context 'database' do
      it 'saves the url object into the database' do
        expect { request }.to change { Url.count }.by(1)
      end
    end

    context 'invalid requests' do
      it 'returns 400 status code if url not given' do
        post '/shorten', {}, CONTENT_TYPE: content_type
        expect(last_response.status).to eq(400)
      end

      it 'returns 409 status code if desired shortcode is already in use' do
        request
        repeated_code = JSON.parse(last_response.body)['shortcode']
        post '/shorten', { url: 'http://www.test44',
                           shortcode: repeated_code }.to_json,
             CONTENT_TYPE: content_type
        expect(last_response.status).to eq(409)
      end

      it 'returns 422 status code if shortcode not match regex' do
        post '/shorten', { url: 'http://www.test44', shortcode: 'ab1' }.to_json,
             CONTENT_TYPE: content_type
        expect(last_response.status).to eq(422)
      end
    end
  end

  # Redirect to the original url test suite
  describe 'GET /:shortcode' do
    context 'valid request' do
      created_url = Url.create(url: 'http://test22.com',
                               shortcode: Url.generate_unique_shortcode)
      before { get "/#{created_url.shortcode}", content_type: content_type }

      it 'returns status code to be 302' do
        expect(last_response.status).to eq(302)
      end

      it 'return header with location matching url' do
        expect(last_response.headers['location']).to eq(created_url.url)
      end
    end

    context 'invalid request' do
      before { get '/1234abcd!!', content_type: content_type }

      it 'returns 404 status code' do
        expect(last_response.status).to eq(404)
      end
    end
  end

  # show stats of shortcode test suite
  describe 'GET /:shortcode/stats' do
    context 'valid request' do
      url = Url.create(url: 'http://test22.com',
                       shortcode: Url.generate_unique_shortcode)
      before { get "/#{url.shortcode}/stats", content_type: content_type }

      it 'returns status code to be 200' do
        expect(last_response.status).to eq(200)
      end

      it 'return response body with proper values' do
        correct_keys = %w[startDate redirectCount lastSeenDate]
        response = JSON.parse(last_response.body)
        expect(response.keys).to eq(correct_keys)
        expect(response['redirectCount']).to eq(url.redirect_count)
      end
    end

    context 'invalid request' do
      before { get '/1234abcd/stats', content_type: content_type }

      it 'returns 404 status code' do
        expect(last_response.status).to eq(404)
      end
    end
  end
end
