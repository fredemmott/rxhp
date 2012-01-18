require 'rxhp/element'
require 'rxhp/fragment'

module Rxhp
  # This defines an element that is only a handy way to think of a
  # tree of other elements - it has no real rendering by itself, just those
  # of its' children.
  #
  # Most of the time, those children will either be ComposableElement's in
  # turn, or subclasses of Rxhp::HtmlElement
  class ComposableElement < Rxhp::Element
    # You don't want to implement this function in your subclasses -
    # just reimplement compose instead.
    #
    # This calls compose, provides the 'yield' magic, and callls render on
    # the output.
    def render options = {}
      self.compose do
        # Allow 'yield' to embed all children
        self.children.each do |child|
          fragment child
        end
      end.render(options)
    end

    # Implement this method - return an Rxhp::Element subclass.
    def compose
      raise NotImplementedError.new
    end

    # Automatically add a foo_bar method to Rxhp scopes when a FooBar
    # subclass of this is created.
    def self.inherited subclass
      # UpperCamelCase => under_scored
      tag_name = subclass.name.gsub(/(.)([A-Z])/, '\1_\2').downcase
      Rxhp::Scope.define_element tag_name, subclass
    end
  end
end
