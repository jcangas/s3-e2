module Pressman
  class Stone
    attr :color

    def initialize(color)
      @color = color
      activate
    end

    def active?
      @active
    end

    def inactive?
      !@active
    end

    def activate
      @active = true
    end

    def deactivate
      @active = false
    end

    def toggle
      @active = !active
    end

  end
end

