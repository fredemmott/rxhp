require 'rxhp/element'

module Rxhp
  class Fragment < Element
    def render options = {}
      self.render_children(options)
    end
  end
end
