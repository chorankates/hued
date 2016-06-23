
module Hued
  class Schedule

    attr_reader :struct
    attr_reader :description, :name, :status, :time

    # TODO struct['command'] has the way to select a scene

    def initialize(struct)
      @struct = struct

      @description = @struct['description']
      @name        = @struct['name']
      @status      = @struct['status']
      @time        = @struct['time']

      # TODO add a logger
    end

    def inspect
      {
        :name        => @name,
        :description => @description,
        :status      => @status,
        :time        => @time, # TODO what's the difference here between this and 'localtime'
      }
    end

    def to_s
      inspect.to_s
    end

  end
end



