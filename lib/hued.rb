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

      @lights    = get_lights(@config)
      @scenes    = get_scenes(@config)
      @schedules = get_schedules(@config)
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
      config = input.nil? ? get_config() : input
      []
    end

    def get_scenes(input = nil)
      config = input.nil? ? get_config() : input
      []
    end

    def get_schedules(input = nil)
      config = input.nil? ? get_config() : input
      []
    end

    def all_lights_on
    end

    def all_lights_off
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

  class Light

  end

  class Scene

  end

end

if $0 == __FILE__

  def parse_input
    options = Hash.new

    parser = OptionParser.new do |o|
      o.on('--ip <ip>', 'IP address of Phillips Hue Hub') do |p|
        options[:ip] = p
      end
      o.on('--token <token>', 'whitelisted token') do |p|
        options[:token] = p
      end
    end

    parser.parse!
    options
  end

  options = parse_input

  hub = Hued::Hub.new(options[:ip], options[:token])

  hub.all_lights_off
  sleep 5
  hub.all_lights_on

end
