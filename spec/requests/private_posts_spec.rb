# frozen_string_literal: true

require 'rails_helper'
require 'byebug'

RSpec.describe 'Posts with authentication', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:user_post) { create(:post, user_id: user.id) }
  let!(:other_user_post) { create(:post, user_id: other_user.id, published: true) }
  let!(:other_user_post_draft) { create(:post, user_id: other_user.id, published: false) }
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}" } }
  let!(:create_params) do
    { 'post' => {
      'title' => 'title',
      'content' => 'content',
      'published' => true
    } }
  end
  let!(:update_params) do
    { 'post' => {
      'title' => 'title',
      'content' => 'content',
      'published' => true
    } }
  end

  describe 'GET /posts/{id}' do
    context 'with valid auth' do
      context "when requesting other's author post" do
        context 'when post is public' do
          before { get "/posts/#{other_user_post.id}", headers: auth_headers }

          context 'payload' do
            subject { payload }
            it { is_expected.to include(:id) }
          end
          context 'response' do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end
        end

        context 'when post is draft' do
          before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }
          context 'payload' do
            subject { payload }
            it { is_expected.to include(:error) }
          end
          context 'response' do
            subject { response }
            it { is_expected.to have_http_status(:not_found) }
          end
        end
      end

      context "when requesting user's post" do
        # puts 'hola'
      end
    end
  end

  describe 'POST /posts' do
    # con auth -> crear
    context 'with valid auth' do
      before { post '/posts', params: create_params, headers: auth_headers }

      context 'payload' do
        subject { payload }
        it { is_expected.to include(:id, :title, :content, :published, :author) }
      end

      context 'response' do
        subject { response }
        it { is_expected.to have_http_status(:created) }
      end
    end
    # sin auth -> !crear -> 401
    context 'without authentication' do
      before { post '/posts', params: create_params }

      context 'payload' do
        subject { payload }
        it { is_expected.to include(:error) }
      end

      context 'response' do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end

  describe 'PUT /posts' do
    # con auth ->
    #       actualizar nuestro
    #       !actualizar nuestro
    context 'with valid auth' do
      context "when updating user's post" do
        before { put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }

        context 'payload' do
          subject { payload }
          it { is_expected.to include(:id, :title, :content, :published, :author) }
          it { expect(payload[:id]).to eq(user_post.id) }
        end

        context 'response' do
          subject { response }
          it { is_expected.to have_http_status(:ok) }
        end
      end

      context "when updating user's post" do
        before { put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }

        context 'payload' do
          subject { payload }
          it { is_expected.to include(:error) }
        end

        context 'response' do
          subject { response }
          it { is_expected.to have_http_status(:not_found) }
        end
      end
    end
    # sin auth -> !actualizar -> 401
    # context 'without authentication' do
    # before { post '/posts', params: create_params }
    #
    # context 'payload' do
    # subject { payload }
    # it { is_expected.to include(:error) }
    # end
    #
    # context 'response' do
    # subject { response }
    # it { is_expected.to have_http_status(:unauthorized) }
    # end
    # end
  end

  private

  def payload
    JSON.parse(response.body).with_indifferent_access
  end
end
