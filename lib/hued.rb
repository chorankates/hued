#!/usr/bin/env ruby
## hued.rb Philips Hue HTTP binding

# TODO create a mock Hub for test/dev, record/playback of a real device should be fine

require 'json'
require 'net/http'
require 'optparse'
require 'yaml'
require 'uri'

$LOAD_PATH << File.dirname(__FILE__)

require 'hued/hub'
require 'hued/light'
require 'hued/logging'
require 'hued/scene'
require 'hued/schedule'
require 'hued/sensor'

module Hued

  class Application

    extend Hued::Logging

    attr_reader :config, :hub, :logger

    # TODO add a logger
    def initialize(config)
      @config = config
      @hub    = Hued::Hub.new(config[:ip], config[:token])

      @logger = Hued::Logging.get_logger(self.class)
      @logger.debug(sprintf('initialized[%s]: [%s]', self.class, self.inspect))

      # this (Hued::Light) is probably not the right place to keep this constant - the method is probably ok
      @colors = Hued::Light::COLOR_NAMES
    end

    def demo
      print @hub.to_s

      print sprintf('turning all lights [off]')
      @hub.all_lights_off

      sleep 2

      print sprintf('turning all lights [on]')
      @hub.all_lights_on

      sleep 2

      print sprintf('turning all lights [off] again')
      @hub.all_lights_off

      @hub.lights.first.on
      @hub.lights.first.off

      @hub.lights.each do |light|
        print sprintf('turning on[%s]', light)
        light.on
        sleep 1
      end

      @hub.lights.reverse.each do |light|
        print sprintf('turning off[%s]', light)
        light.off
        sleep 1
      end

      @hub.all_lights_on

      @hub.lights.each do |light|
        print sprintf('turning [%s] red', light)
        light.color = 'red'
        sleep 1
      end

      steps = [0, 25, 50, 75, 100]

      @hub.lights.each do |light|
        print sprintf('brightness step up [%s]', light)
        steps.each do |b|
          print sprintf('[%s]: [%s]', light, b)
          light.brightness = b
          sleep 1
        end
      end

      @hub.lights.each do |light|
        print sprintf('brightness step down [%s]', light)
        steps.reverse.each do |b|
          print sprintf('[%s]: [%s]', light, b)
          light.brightness = b
          sleep 1
        end
      end

      @hub.nyan_cat

    end

    def self.impersonate
      # stand up what looks like a web server
      server = nil

      begin
        server = TCPServer.new('0.0.0.0', 80) # will need sudo/root for this
      rescue Errno::EADDRINUSE
        @logger.error('unable to bind to port, already in use')
        Kernel.exit 1
      rescue Errno::EACCES
        @logger.error('unable to bind to port, need root priveleges')
        Kernel.exit 2
      end

      puts sprintf('listening at[http://%s:%s]', server.addr.last, server.addr[1])

      while true
        socket  = server.accept
        request = socket.gets

        puts sprintf('  received[%s] from[%s]', request.chomp, socket.peeraddr.last)

        response = [
          'HTTP/1.1 200 OK',
          'Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
          'Pragma: no-cache',
          'Expires: Mon, 1 Aug 2011 09:00:00 GMT',
          'Connection: close',
          'Access-Control-Max-Age: 3600',
          'Access-Control-Allow-Credentials: true',
          'Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE, HEAD',
          'Access-Control-Allow-Headers: Content-Type',
          'Content-type: application/json',
          "\r\n",
          get_json_config,
        ].join("\n")

        socket.print(response)
        socket.close

        # TODO make it easier to determine the actual token
      end
    end

    def repl

      repl_usage
      print sprintf('Hued::Hub:[%s]%s', @hub, "\n")

      loop do

        print 'hued> '

        input  = gets.chomp!
        tokens = input.split("\s")

        target  = tokens.shift
        action  = tokens.shift
        options = tokens

        if target.match(/q(?:uit)|e(?:xit)/)
          break
        elsif target.match(/^light/)
          # light control
          p 'foo'
          if action.eql?('list')
            @hub.list(@hub.lights)
          end

          if target.eql?('all')
            # operate on all lights
            p 'DBGZ'
          else
            # operate on name, integer, CSV of names|integers, range of integers
            p 'DBGZ'
          end
        elsif target.match(/^hub/)
          if action.eql?('refresh')
            @hub.refresh
          end
        elsif target.match(/^scene/)
          if action.eql?('list')
            @hub.list(@hub.scenes)
          end
        elsif target.match(/^schedule/)
          if action.eql?('list')
            @hub.list(@hub.schedules)
          end
        elsif target.match(/^sensor/)
          if action.eql?('list')
            @hub.list(@hub.sensors)
          end
        elsif target.match(/(?:h)elp/)
          repl_usage(action)
        end

        p 'DBGZ' if nil?
      end

    end

    def repl_usage(action = nil)
      if action.nil?
        print "usage:\n"
        {
          :hub      => '<range/name> <action> [options]',
          :light    => '<range/name> <action> [options]',
          :scene    => '<name> <action> [options]',
          :schedule => '<name> <action> [options]',
          :sensor   => '<range/name> <action> [options]',

          :help     => '[action]',
        }.each do |face, parameters|
          print sprintf('  %s %s %s', face.to_s, parameters, "\n")
        end

        print "all targets support the actions[add, delete, list]\n"
      else
        # TODO action specific parameters
      end

    end

    def nyancat
      while true do
        @hub.lights.each do |light|
          light.color(next_color)
        end
      end
    end

    def get_json_config
      config = File.expand_path(sprintf('%s/../resources/api/config', File.dirname(__FILE__)))
      File.read(config)
    end

    private

    # returns the next color in a linked-array by shifting and pushing
    def next_color
      nc = @colors.shift
      @colors.push(nc)
      nc
    end

  end

  class Utility

    # TODO need to figure out how we want to do logging here

    ## helper functions
    def self.get_http(url)
      uri      = URI.parse(url)
      http     = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = false
      request  = Net::HTTP::Get.new(uri.request_uri)
      http.request(request)
    end

    def self.put_http(url, body)
      uri     = URI.parse(url)
      http    = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri.request_uri)

      request.add_field('Content-Type', 'application.json')
      request.body = body.to_json
      http.request(request)
    end

    def self.ppp(hash, level = 0)
      output = sprintf('%s{%s', ' ' * level, "\n") # TODO should probably contextualize this and allow for arrays too
      hash.each do |k, v|
        if v.is_a?(Hash)
          output << sprintf('%s%s => %s', ' ' * (level + 1), k, "\n")
          output << ppp(v, level + 1)
        else
          output << sprintf('%s%s => %s%s', ' ' * (level + 1), k, v, "\n")
        end
      end
      output << sprintf('%s}%s', ' ' * level, "\n")

      output
    end

  end

end