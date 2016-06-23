
module Hued
  class Light

    # specified in RGB ascending order
    COLORS = {
      :red          => '',
      :orange       => '',
      :yellow       => '',
      :green        => '',
      :green_hunter => '',
      :blue         => '',
      :purple       => '',
    }

    # hey momo, stop throwing shades
    SHADES = {
      :white      => '',
      :white_soft => '',
    }

    attr_reader :struct
    attr_reader :state, :brightness, :color, :reachable, :type, :name, :model, :mac, :version

    def initialize(struct)
      @struct = struct

      @state      = @struct['state']['on'].eql?(true) ? :on : :off
      @brightness = @struct['state']['bri']
      @color      = nil # still need to determine how we're doing this.. model it separately with bri,hue,sat, and xy coords?
      @reachable  = @struct['state']['reachable']
      @type       = @struct['type']
      @name       = @struct['name']
      @model      = @struct['modelid']
      @mac        = @struct['uniqueid']
      @version    = @struct['swversion']

      # TODO add a real logger here
      #@logger = nil
      #@logger.debug(sprintf('initialized[%s]: [%s]', self.class, self.inspect))
    end

    def inspect
      {
        :name  => @name,
        :state => @state,
        :color => @color,
        :type  => @type,
      }
    end

    def to_s
      inspect.to_s
    end


    def on; end
    def off; end

    def name(new_name = nil)
      if new_name.nil?
        @struct.name
      else
        @struct.name = new_name
      end
    end

    def color(new_color = nil)
      if new_color.nil?
        # TODO come up with a way to normalize the color into a Hued::Light::COLOR
        p 'DBGZ' if nil?
      elsif COLORS.include?(new_color)
        @struct.color = new_color
      else
        ## BAD NEWS BEARS
        @logger.error(sprintf('BAD NEWS BEARS'))
      end
    end

    def brightness(new_brightness = nil)
      if new_brightness.nil?
        # TODO what is the openstruct key here?
        p 'DBGZ' if nil?
      else
        # TODO what is the open struct key here?
        p 'DBGZ' if nil?
      end
    end

  end
end
