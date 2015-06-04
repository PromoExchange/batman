require 'rails_helper'

describe 'Messages API' do
  let(:current_api_user) do
    user = Spree.user_class.new(email: 'spree@example.com',
                                password: 'password')
    user.generate_spree_api_key!
    user
  end

  it 'must require an api key' do
    message = FactoryGirl.create(:message)

    get "/api/messages/#{message.id}"

    expect(response).to have_http_status(401)
  end

  it 'gets a list of messages' do
    FactoryGirl.create_list(:message, 10)

    get '/api/messages', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'gets a single message' do
    message = FactoryGirl.create(:message)

    get "/api/messages/#{message.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['body']).to eq(message.body)
    expect(json['subject']).to eq(message.subject)
  end

  it 'sends an update message' do
    message = FactoryGirl.create(:message, subject: 'put subject')

    put "/api/messages/#{message.id}", message.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['subject']).to eq('put subject')
  end

  it 'creates a message' do
    message = FactoryGirl.build(:message, subject: 'posty subject')

    post '/api/messages', message.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['subject']).to eq('posty subject')
  end

  it 'deletes a message' do
    message = FactoryGirl.create(:message)

    delete "/api/messages/#{message.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end
end