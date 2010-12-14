require 'rubygems'
require 'typhoeus'
require 'json'

class User
  class << self; attribute_accessor :base_url end

  def self.find_by_name(name)
    response =  Typhoeus::Request.get("#{base_ur}/api/v1/users/#{name}")
    if response.code == 200
      JSON.parse(respond.body)
    elsif response.code == 404
      nil
    else
      raise response.body
    end
  end

  def self.create(attributes)
    response = Typheous::Request.post("#{base_url}/api/v1/users", :body => attributes.to_json)
    if response.code == 200
      JSON.parse(response.body)
    else
      raise response.body
    end
  end
end
