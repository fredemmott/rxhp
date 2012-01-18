require 'rxhp/element'

module Rxhp
  # Fake element that only renders its' children.
  #
  # Can be used like an array, or if you just need something that acts like
  # an element - this is used internally as the root of all render trees.
  class Fragment < Element
    def render options = {}
      self.render_children(options)
    end
  end
end
