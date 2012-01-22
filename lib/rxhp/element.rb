require 'rxhp/constants'
require 'rxhp/scope'

module Rxhp
  # Base class for all element-like things in RXHP.
  #
  # Everything in the tree is a subclass of this, a subclass of String,
  # something that responds nicely to to_s, or something that will cause en
  # error at render-time :p
  class Element
    include ::Rxhp::Scope
    attr_accessor :attributes, :children

    def initialize attributes = {}
      @attributes = attributes
      @children = Array.new
      validate!
    end

    def children?
      !children.empty?
    end

    def valid?
      begin
        validate!
        true
      rescue Rxhp::ValidationError
        false
      end
    end

    def validate!
      # no-op
    end

    # Return a flat HTML string for this element and all its' decendants.
    #
    # You probably don't want to implement this yourself - interesting
    # implementations are in Rxhp::Fragment, Rxhp::HtmlElement, and
    # Rxhp::ComposableElement
    def render options = {}
      raise NotImplementedError.new
    end

    # Called when something that isn't an element is found in the tree.
    #
    # Implemented in Rxhp::HtmlElement.
    def render_string string, options
      raise NotImplementedError.new
    end


    # Iterate over all the children, calling render.
    def render_children options = {}
      return if children.empty?

      flattened_children.map{ |child| render_child(child, options) }.join
    end

    # Fill default options
    def fill_options options
      {
        :pretty => true,
        :format => Rxhp::HTML_FORMAT,
        :skip_doctype => false,
        :doctype => Rxhp::HTML_5,
        :depth => 0,
        :indent => 2,
      }.merge(options)
    end

    private

    def render_child child, options
      case child
      when Element
        child.render(options)
      when String
        self.render_string(child, options)
      when Enumerable
        child.map{ |grandchild| render_child(grandchild, options) }.join
      else
        self.render_string(child.to_s, options)
      end
    end

    def flattened_children
      no_frags = []
      children.each do |node|
        if node.is_a? Rxhp::Fragment
          no_frags += node.children
        else
          no_frags.push node
        end
      end

      previous = nil
      no_consecutive_strings = []
      no_frags.each do |node|
        if node.is_a?(String) && previous.is_a?(String)
          previous << node
        else
          no_consecutive_strings.push node
          previous = node
        end
      end

      no_consecutive_strings
    end
  end
end
