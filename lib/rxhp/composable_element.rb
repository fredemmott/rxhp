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
  end
end
