# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Posts', type: :request do
  describe 'GET /post' do
    before { get '/post' }
    it 'should return OK' do
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(response).to have_http_status(200)
    end
    describe 'with data in the DB' do
      let(:posts) { create_list(:post, 10, published: true) }
      it 'should return status code 200' do
        payload = JSON.parse(response.body)
        expect(payload.size).to eq(posts.size)
        expect(response).to have_http_status(200)
      end
    end
  end
end

RSpec.describe 'Post show', type: :request do
  describe 'GET /post/{id}' do
    let(:post) { create(:post) }
    it 'should return a post' do
      get "/post/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['id']).to eq(post.id)
      expect(response).to have_http_status(200)
    end
  end
end
