require 'hued/logging'

# temporary?
require 'sequel'

module Hued
  class Hub

    extend Hued::Logging

    attr_reader :logger
    attr_accessor :config, :lights, :scenes, :schedules, :sensors

    # TODO need to break down @config and expose useful pieces
    def initialize(ip, token)
      @ip    = ip
      @token = token

      raise "no IP specified" if @ip.nil?
      raise "no token specified" if @token.nil?

      @config = get_config()

      # TODO should probably let users decide which ones to call
      @lights    = get_lights()
      @scenes    = get_scenes()
      @schedules = get_schedules()
      @sensors   = get_sensors()

      @logger = Hued::Logging.get_logger(self.class)

      @logger.debug(sprintf('initialized: [%s]', self.to_s))
      @logger.info(sprintf('found[%s] lights: [%s]', @lights.size, @lights.join("\n\t")))
      @logger.info(sprintf('found[%s] scenes: [%s]', @scenes.size, @scenes.join("\n\t")))
      @logger.info(sprintf('found[%s] schedules: [%s]', @schedules.size, @schedules.join("\n\t")))
    end

    def inspect
      {
        :ip        => @ip,
        :token     => @token,
        :lights    => @lights.size,
        :scenes    => @scenes.size,
        :schedules => @schedules.size,
        :sensors   => @sensors.size,
      }
    end

    def to_s
      inspect.to_s
    end

    def list(object)
      output = object.collect { |e| e.to_s }
      print output.join("\n")
    end

    def get_config
      JSON.parse(
        Hued::Utility.get_http(
          get_url('config')).body
      )
    end

    def get_lights(input = nil)
      lights   = Array.new
      response = JSON.parse(
        Hued::Utility.get_http(
          get_url('lights')).body
      )

      response.each do |_i, hash|
        lights << Hued::Light.new(hash)
      end

      lights
    end

    def get_scenes(input = nil)
      scenes = Array.new
      response = JSON.parse(
        Hued::Utility.get_http(
          get_url('scenes')).body
      )

      response.each do |_i, hash|
        scenes << Hued::Scene.new(hash)
      end

      scenes
    end

    def get_schedules(input = nil)
      schedules = Array.new
      response  = JSON.parse(
        Hued::Utility.get_http(
          get_url('schedules')).body
      )

      response.each do |_i, hash|
        schedules << Hued::Schedule.new(hash)
      end
      schedules
    end

    def get_sensors(input = nil)
      schedules = Array.new
      response  = JSON.parse(
        Hued::Utility.get_http(
          get_url('sensors')).body
      )

      response.each do |_i, hash|
        schedules << Hued::Sensor.new(hash)
      end
      schedules
    end

    def all_lights_on
      url     = get_url('groups/0/action')
      payload = { :on => true }
      Hued::Utility.put_http(url, payload)
    end

    def all_lights_off
      url     = get_url('groups/0/action')
      payload = { :on => false }
      Hued::Utility.put_http(url, payload)
    end

    # TODO should leverage this somehow in initialize, had to externalize for repl
    def refresh
      @config = get_config()
      @lights    = get_lights()
      @scenes    = get_scenes()
      @schedules = get_schedules()
      @sensors   = get_sensors()
    end

    def initialize_db
      @db.create_table? :lights do
        primary_key :id
        String :name
        String :state
        foreign_key :color
        String :type
        Date :created
        Date :updated # this will actually be 'refreshed', will not add duplicate entries
      end

      @db.create_table? :colors do
        primary_key :id
        String :name
        Fixnum :brightness
        Fixnum :hue
        Fixnum :saturation
        Float :x
        Float :y
      end

      @db.create_table? :schedules do
        primary_key :id
        String :name
        foreign_key :scene # ugh, do we care this much?
        String :schedule # ugh, not sure what the key is here.. WIP
      end

      @db.create_table? :sensors do
        primary_key :id
        String :name
        String :model
      end

    end

    def backup; end

    def restore; end

    # Hub specific helper methods
    def get_url(method)
      sprintf('http://%s/api/%s/%s', @ip, @token, method)
    end

  end
end