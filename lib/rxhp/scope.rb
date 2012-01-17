module Rxhp
  module Scope
    # Allows you to do this:
    # inner = body { 'hi' }
    # html do
    #   fragment inner
    # end
    def fragment x
      self.render_context.children.push x
    end
    alias :frag :fragment

    def self.define_element name, klass
      Rxhp::Scope.send(:define_method, name) do |children = nil, attributes = {}, &block|
        if children.is_a?(Hash) && attributes.empty?
          attributes = children
          children = nil
        end

        element = klass.new(attributes)

        context = self.render_context
        context.children.push element

        if children
          if children.is_a? Array
            children.each do |child|
              element.children.push child
            end
          else
            element.children.push children # well, child
          end
        end

        if block
          self.sub_render(element) do
            result = block.call
            if result && result.is_a?(String)
              element.children.push result
            end
          end
        end
        element
      end
    end
  end
end
