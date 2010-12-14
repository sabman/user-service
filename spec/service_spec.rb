require File.dirname(__FILE__) + '/../service'
require 'sinatra'
require 'rack/test'
require 'rspec'

set :environment, :test

def app
  Sinatra::Application
end

include Rack::Test::Methods

describe 'service' do

  before(:each) do
    User.delete_all
  end

  describe 'GET on /api/v1/users/:id' do
    before(:each) do
      User.create!(
        :name     => 'shoaib',
        :email    => 'shoaib@nomad-labs.com',
        :password => 'strongpass',
        :bio      => 'rubyist'
      )
    end

    it 'should return a user by name' do
      get '/api/v1/users/shoaib'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes['user']['name'].should == 'shoaib'
    end

    it 'should return a user with an email' do
      get '/api/v1/users/shoaib'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes['user']['email'] == 'shoaib@nomad-labs.com'
    end

    it 'should not return a user\'s password' do
      get '/api/v1/users/shoaib'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes['user'].should_not have_key('password')
    end

    it 'should return a user with a bio' do
      get '/api/v1/users/shoaib'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes['bio'] == 'rubyist'
    end

    it 'should return a 404 for a user that doesn\'t exist' do
      get '/api/v1/users/foo'
      last_response.status.should == 404
    end

  end

  describe 'POST /api/v1/users' do
    it 'should create a user' do
      post '/api/v1/users', 
        { :name     => 'trotter',
          :email    => 'no spam',
          :password => 'whatever', 
          :bio      => 'southern belle'
        }.to_json
      last_response.should be_ok

      get '/api/v1/users/trotter'
      attributes = JSON.parse(last_response.body)
      attributes['user']['name'].should == 'trotter'
      attributes['user']['email'].should == 'no spam'
      attributes['user']['bio'].should == 'southern belle'
    end
  end

  describe 'PUT /api/v1/users/:id' do
    it 'should update a user' do
      User.create(
        :name     => "bryan", 
        :email    => "no spam",
        :password => "whatever",
        :bio      => "rspec master"
      )
      put '/api/v1/users/bryan', {:bio => 'testing freak'}.to_json
      last_response.should be_ok

      get '/api/v1/users/bryan'
      attributes = JSON.parse(last_response.body)
      attributes['user']['bio'].should == 'testing freak'
    end
  end

  describe 'DELETE /api/v1/users/:id' do
    it 'should delete a user' do
      User.create!(
        :name     => 'francis',
        :email    => 'no spam',
        :password => 'secrets',
        :bio      => 'hipster'
      )

      delete '/api/v1/users/francis'
      last_response.should be_ok

      get '/api/v1/users/fransis'
      last_response.status.should == 404
    end
  end

  describe 'POST on /api/v1/users/:id/sessions' do
    before(:each) do
      User.create!(:name => 'josh', :password => 'berlin.rb rules')
    end

    it 'should return the user object on valid credentials' do
      post '/api/v1/users/josh/sessions', {:password => 'berlin.rb rules'}.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes['user']['name'].should == 'josh'
    end

    it 'should fail on invalid credentials' do
      post '/api/v1/users/josh/sessions', {:password => 'wrong'}.to_json
      last_response.status.should == 400
    end
  end
end