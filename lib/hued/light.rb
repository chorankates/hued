
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

    def initialize(struct)
      @struct = struct

      # TODO add a real logger here
      @logger = nil
      @logger.debug(sprintf('initialized[%s]: [%s]', self.class, self.inspect))
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
