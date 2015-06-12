require 'rails_helper'
require 'spree_shared'

describe 'Messages API' do
  include_context 'spree_shared'

  it 'should require an api key' do
    message = FactoryGirl.create(:message)

    get "/api/messages/#{message.id}"

    expect(response).to have_http_status(401)
  end

  it 'should get a list of messages' do
    FactoryGirl.create_list(:message, 10)

    get '/api/messages', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a page of messages' do
    FactoryGirl.create_list(:message, 10)

    get '/api/messages?page=2&per_page=3', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(3)
  end

  it 'should get a single message' do
    message = FactoryGirl.create(:message)

    get "/api/messages/#{message.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['body']).to eq(message.body)
    expect(json['subject']).to eq(message.subject)
  end

  it 'should update a message' do
    message = FactoryGirl.create(:message, subject: 'put subject')

    put "/api/messages/#{message.id}", message.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['subject']).to eq('put subject')
  end

  it 'should create a message' do
    message = FactoryGirl.build(:message, subject: 'posty subject')

    post '/api/messages', message.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['subject']).to eq('posty subject')
  end

  it 'should not create a duplicate message' do
    message = FactoryGirl.create(:message)

    post '/api/messages', message.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should deletes a message' do
    message = FactoryGirl.create(:message)

    delete "/api/messages/#{message.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end
end
