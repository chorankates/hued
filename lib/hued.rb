#!/usr/bin/env ruby
## hued.rb Philips Hue HTTP binding

require 'json'
require 'net/http'
require 'optparse'
require 'yaml'
require 'uri'

module Hued

  class Hub

    attr_accessor :lights, :scenes, :schedules

    def initialize(ip, token)
      @ip    = ip
      @token = token

      raise "no IP specified" if @ip.nil?
      raise "no token specified" if @token.nil?

      @config = get_config()

      @lights    = get_lights()
      @scenes    = get_scenes()
      @schedules = get_schedules()
    end

    def inspect
      {
        :ip        => @ip,
        :token     => @token,
        :lights    => @lights.size,
        :scenes    => @scenes.size,
        :schedules => @schedules.size,
      }
    end

    def to_s
      inspect.to_s
    end

    def get_config
      JSON.parse(get_url(get_path('config')).body)
    end

    def get_lights(input = nil)
      lights   = Array.new
      response = JSON.parse(get_url(get_path('lights')).body)
      response.each do |_i, hash|
        lights << OpenStruct.new(hash)
      end

      lights
    end

    def get_scenes(input = nil)
      scenes = Array.new
      response = JSON.parse(get_url(get_path('scenes')).body)
      response.each do |_i, hash|
        scenes << OpenStruct.new(hash)
      end

      scenes
    end

    def get_schedules(input = nil)
      schedules = Array.new
      response  = JSON.parse(get_url(get_path('schedules')).body)
      response.each do |_i, hash|
        schedules << OpenStruct.new(hash)
      end

      schedules
    end

    def all_lights_on
      raise 'not implemented'
    end

    def all_lights_off
      raise 'not implemented'
    end

    ## helper functions
    def get_path(method)
      sprintf('http://%s/api/%s/%s', @ip, @token, method)
    end

    def get_url(url)
      uri      = URI.parse(url)
      http     = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = false
      request  = Net::HTTP::Get.new(uri.request_uri)
      http.request(request)
    end

    def post_url(url, body)
    end

  end

end

if $0 == __FILE__
  raise "you're probably looking for bin/hued"
end
