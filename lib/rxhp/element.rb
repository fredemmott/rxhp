require 'rxhp/mixin'
require 'rxhp/constants'


module Rxhp
  # Base class for all element-like things in RXHP.
  #
  # Everything in the tree is a subclass of this, a subclass of String,
  # something that responds nicely to to_s, or something that will cause en
  # error at render-time :p
  class Element
    include ::Rxhp::Mixin
    attr_accessor :attributes, :children

    def initialize attributes = {}
      @attributes = attributes
      @children = Array.new
    end

    def children?
      !children.empty?
    end

    # Return a flat HTML string for this element and all its' decendants.
    #
    # You probably don't want to implement this yourself - interesting
    # implementations are in Rxhp::Fragment, Rxhp::HtmlElement, and
    # Rxhp::ComposableElement
    def render options = {}
      raise NotImplementedError.new
    end

    protected

    # Called when something that isn't an element is found in the tree.
    #
    # Implemented in Rxhp::HtmlElement.
    def render_string string, options
      raise NotImplementedError.new
    end


    # Iterate over all the children, calling render.
    def render_children options
      return if children.empty?

      out = String.new
      children.each do |child|
        case child
        when Element
          out += child.render(options)
        when String
          # render_context.render_string is used instead of
          # self.render_string as the call depth isn't guaranteed to be the
          # same as the node nesting depth.
          #
          # See Rxhp::Renderer for more infromation.
          out += render_context.render_string(child, options)
        else
          out += render_context.render_string(child.to_s, options)
        end
      end
      out
    end

    # Fill default options
    def fill_options options
      {
        :pretty => true,
        :format => Rxhp::HTML_FORMAT,
        :skip_doctype => false,
        :doctype => Rxhp::HTML_4_01_TRANSITIONAL,
        :depth => 0,
        :indent => 2,
      }.merge(options)
    end
  end
end
