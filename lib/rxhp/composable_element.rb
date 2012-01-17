require 'rxhp/element'
require 'rxhp/fragment'

module Rxhp
  class ComposableElement < Rxhp::Element
    def render options = {}
      self.compose do
        # Allow 'yield' to embed all children
        self.children.each do |child|
          fragment child
        end
      end.render(options)
    end

    def compose
      raise NotImplementedError.new
    end

    def self.inherited subclass
      # UpperCamelCase => under_scored
      tag_name = subclass.name.gsub(/(.)([A-Z])/, '\1_\2').downcase
      Rxhp::Scope.define_element tag_name, subclass
    end
  end
end
