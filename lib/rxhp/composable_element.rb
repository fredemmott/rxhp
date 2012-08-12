require 'rxhp/custom_element'
require 'rxhp/fragment'

module Rxhp
  # This defines an element that is only a handy way to think of a
  # tree of other elements - it has no real rendering by itself, just those
  # of its' children.
  #
  # Most of the time, those children will either be ComposableElement's in
  # turn, or subclasses of Rxhp::HtmlElement
  class ComposableElement < Rxhp::CustomElement
    # You don't want to implement this function in your subclasses -
    # just reimplement compose instead.
    #
    # This calls compose, provides the 'yield' magic, and callls render on
    # the output.
    def render options = {}
      validate!
      self.compose do
        # Allow 'yield' to embed all children
        self.children.each do |child|
          fragment child
        end
      end.render(options)
    end

    # Implement this method - return an Rxhp::Element subclass.
    #
    # @yieldreturn child elements
    def compose
      raise NotImplementedError.new
    end

    # Automatically add a foo_bar method to Rxhp scopes when a FooBar
    # subclass of this is created.
    def self.inherited subclass
      Rxhp::AttributeValidator.inherited(subclass)
      full_name = subclass.name
      parts = full_name.split('::')
      klass_name = parts.pop
      namespace = Kernel
      parts.each do |part|
        namespace = namespace.const_get(part)
      end
      # UpperCamelCase => under_scored
      tag_name = klass_name.gsub(/(.)([A-Z])/, '\1_\2').downcase

      Rxhp::Scope.define_element tag_name, subclass, namespace
    end
  end
end
