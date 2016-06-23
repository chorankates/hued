
module Hued
  class Sensor

    attr_reader :struct
    attr_reader :state, :name, :type, :model, :version, :updated

    def initialize(struct)
      @struct = struct

      @model   = @struct['modelid']
      @name    = @struct['name']
      @type    = @struct['type']
      @state   = @struct['config']['on'].eql?(true) ? :on : :off
      @updated = @struct['state']['lastupdated']
      @version = @struct['swversion']

    end

    def inspect
      {
        :name    => @name,
        :state   => @state,
        :model   => @model,
        :type    => @type,
        :updated => @updated,
        :version => @version,
      }
    end

    def to_s
      inspect.to_s
    end

  end
end
