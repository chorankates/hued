
module Hued

  class Color
    attr_reader :config
    attr_reader :brightness, :hue, :saturation, :x, :y

    def initialize(input)
      @config = input

      # TODO some error checking
      @name       = @config[:name]
      @brightness = @config[:brightness]
      @hue        = @config[:hue]
      @saturation = @config[:saturation]
      @x          = @config[:x]
      @y          = @config[:y]
    end

    def inspect
      {
        # TODO delete :name if :unknown
        :name       => @name,
        :brightness => @brightness,
        :hue        => @hue,
        :saturation => @saturation,
        :x          => @x,
        :y          => @y,
      }
    end

    def to_s
      inspect.to_s
    end

  end

  class Light

    extend Hued::Logging

    # specified in RGB ascending order
    # TODO these are all really 'blue', need to work out details
    COLORS = {
      :red          => Hued::Color.new({:name => :red, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
      :orange       => Hued::Color.new({:name => :orange, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
      :yellow       => Hued::Color.new({:name => :yellow, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
      :green        => Hued::Color.new({:name => :green, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
      :green_hunter => Hued::Color.new({:name => :green_hunter, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
      :blue         => Hued::Color.new({:name => :blue, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
      :purple       => Hued::Color.new({:name => :purple, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
    }

    # hey momo, stop throwing shades
    SHADES = {
      :white      => Hued::Color.new({:name => :white, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
      :white_soft => Hued::Color.new({:name => :white_soft, :brightness => 253, :hue => 47110, :saturation => 253, :x => 0.1393, :y => 0.0813}),
    }

    attr_reader :logger, :struct
    attr_reader :state, :brightness, :color, :reachable, :type, :name, :model, :mac, :version

    def initialize(struct)
      @struct = struct

      @state      = @struct['state']['on'].eql?(true) ? :on : :off
      @brightness = @struct['state']['bri']
      @reachable  = @struct['state']['reachable']
      @type       = @struct['type']
      @name       = @struct['name']
      @model      = @struct['modelid']
      @mac        = @struct['uniqueid']
      @version    = @struct['swversion']

      @color = Hued::Color.new(
        {
          :name       => :unknown,
          :brightness => @struct['state']['bri'],
          :hue        => @struct['state']['hue'],
          :saturation => @struct['state']['sat'],
          :x          => @struct['state']['xy'].first,
          :y          => @struct['state']['xy'].first,
        }
      )

      @logger = Hued::Logging.get_logger(self.class)
      @logger.debug(sprintf('initialized[%s]: [%s]', self.class, self.inspect))
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
