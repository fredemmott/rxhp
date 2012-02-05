require 'rxhp/element'

module Rxhp
  # Fake element that only renders its' children.
  #
  # Can be used like an array, or if you just need something that acts like
  # an element - this is used internally as the root of all render trees.
  #
  # You probably don't want to use this directly, as it doesn't know to
  # render strings. You might want {HtmlFragment} instead.
  class Fragment < Element
    # Call {#render_children}
    def render options = {}
      self.render_children(options)
    end
  end
end

Rxhp::Scope.define_element :fragment, Rxhp::Fragment
Rxhp::Scope.define_element :frag, Rxhp::Fragment
