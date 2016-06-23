
module Hued
  class Scene

    attr_reader :struct
    attr_reader :name, :lights, :picture, :updated

    def initialize(struct)
      @struct = struct

      @name    = @struct['name']
      @lights  = @struct['lights'] # TODO can we do something here to turn the elements into a range?
      @picture = @struct['picture']
      @updated = @struct['lastupdated']

      # TODO add logger
    end

    def inspect
      {
        :name   => @name,
        :lights  => @lights,
        :picture => @picture,
        :updated => @updated,
      }
    end

    def to_s
      inspect.to_s
    end


  end
end
