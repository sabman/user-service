require 'pp'
require 'rubygems'
require 'active_record'
require 'sinatra'
require './models/user'

#setup the environment
env_index = ARGV.index("-e")
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV['SENATRA_ENV'] || 'development'
databases = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(databases[env])

if env == 'test'
  puts 'starting in test mode'
  User.destroy_all
  User.create(
    :name => 'shoaib',
    :email => 'shoaib@nomad-labs.com',
    :bio => 'spatial dude'
  )
end

# HTTP entry points
# get a user by name
get '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.to_json
  else
    error 404, {:error => 'user not found' }.to_json
  end
end

post '/api/v1/users' do
  begin
    user = User.create(JSON.parse(request.body.read))
    if user.valid?
      user.to_json
    else
      error 400, user.errors.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end

put '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    begin
      if user.update_attributes(JSON.parse(request.body.read))
        user.to_json
      else
        error 400, user.errors.to_json
      end
    rescue => e
      error 400, e.message.to_json
    end
  else
    error 400, {:error => 'user not found'}.to_json
  end
end

delete '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    begin
      user.destroy
      user.to_json
    rescue => e
      error 400, e.message.to_json
    end
  else
    error 404, {:error => 'user not found'}.to_json
  end
end

post '/api/v1/users/:name/sessions' do
  begin
    attributes = JSON.parse(request.body.read)
    user = User.find_by_name_and_password(params[:name], attributes['password'])
    if user
      user.to_json
    else
      error 400, {:error => 'invalid login credentials'}.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end

