
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


      # TODO add an actual logger
      @logger = nil

      @logger.info(sprintf('initialized: [%s]', self.to_s))
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
      }
    end

    def to_s
      inspect.to_s
    end

    def get_config
      JSON.parse(get_http(get_url('config')).body)
    end

    def get_lights(input = nil)
      lights   = Array.new
      response = JSON.parse(get_http(get_url('lights')).body)
      response.each do |_i, hash|
        lights << Hued::Light.new(hash)
      end

      lights
    end

    def get_scenes(input = nil)
      scenes = Array.new
      response = JSON.parse(get_http(get_url('scenes')).body)
      response.each do |_i, hash|
        scenes << Hued::Scene.new(hash)
      end

      scenes
    end

    def get_schedules(input = nil)
      schedules = Array.new
      response  = JSON.parse(get_http(get_url('schedules')).body)
      response.each do |_i, hash|
        schedules << Hued::Schedule.new(hash)
      end
      schedules
    end

    def all_lights_on
      url     = get_url('groups/0/action')
      payload = { :on => true }
      put_http(url, payload)
    end

    def all_lights_off
      url     = get_url('groups/0/action')
      payload = { :on => false }
      put_http(url, payload)
    end

    def backup; end

    def restore; end

    # Hub specific helper methods
    def get_url(method)
      sprintf('http://%s/api/%s/%s', @ip, @token, method)
    end

  end
end