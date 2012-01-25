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
    # A name => value map of attributes.
    attr_accessor :attributes
    # A list of child elements of this one.
    attr_accessor :children

    # Construct a new element with no children.
    def initialize attributes = {}
      @attributes = attributes
      @children = Array.new
      validate!
    end

    # Whether or not this element has any child element.
    def children?
      !children.empty?
    end

    # Whether there are any detectable problems with this element.
    #
    # See {AttributeValidator} for an example.
    #
    # You probably don't want to override this function in your subclasses;
    # instead, you probably want to change {#validate!} to recognize your
    # validations - all this does is check that it {#validate!} executes
    # without raising a {ValidationError}.
    def valid?
      begin
        validate!
        true
      rescue Rxhp::ValidationError
        false
      end
    end

    # Check that this element is valid.
    #
    # @raise Rxhp::ValidationError if a problem is found.
    def validate!
      # no-op
    end

    # Return a flat HTML string for this element and all its' decendants.
    #
    # You probably don't want to implement this yourself - interesting
    # implementations are in {Fragment}, {HtmlElement}, and
    # {ComposableElement}.
    #
    # Valid options include:
    # +:pretty+:: add whitespace to make the output more readable. Defaults
    #             to true.
    # +:indent+:: how many spaces to use to indent when +:pretty+ is true.
    # +:format+:: See {Rxhp} for values. Default is {Rxhp::HTML_FORMAT}
    # +:skip_doctype+:: Self explanatory. Defaults to false.
    # +:doctype+:: See {Rxhp} for values. Default is {Rxhp::HTML_5}
    def render options = {}
      raise NotImplementedError.new
    end

    # Called when something that isn't an element is found in the tree.
    #
    # Implemented in {HtmlElement}.
    def render_string string, options
      raise NotImplementedError.new
    end


    # Iterate over all the children, calling render.
    def render_children options = {}
      return if children.empty?

      flattened_children.map{ |child| render_child(child, options) }.join
    end

    # Fill default render options.
    #
    # These are as defined for {#render}, with the addition of a
    # +:depth+ value of 0. Other values aren't guaranteed to stay fixed,
    # check source for current values.
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

    # Normalize the children.
    #
    # For example, turn +['foo', 'bar']+ into +['foobar']+.
    #
    # This is needed to stop things like pretty printing adding extra
    # whitespace between the two strings.
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
