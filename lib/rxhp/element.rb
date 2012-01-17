require 'rxhp/mixin'
require 'rxhp/constants'

module Rxhp
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

    def render options = {}
      raise NotImplementedError.new
    end

    protected

    def render_string string, options
      raise NotImplementedError.new
    end

    def render_children options
      return if children.empty?

      out = String.new
      children.each do |child|
        case child
        when Element
          out += child.render(options)
        when String
          out += render_context.render_string(child, options)
        else
          out += render_context.render_string(child.to_s, options)
        end
      end
      out
    end

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
