module Rxhp
  # A place for factory methods to be defined.
  #
  # These are methods like Rxhp::Scope#h1 which creates an Rxhp::Html::H1
  # instance.
  #
  # The actual HTML classes are defined in rxhp/html.rb
  #
  module Scope
    # Helper function to append a child to the current context.
    # Allows you to do this:
    #   inner = body { 'hi' }
    #   html do
    #     fragment inner
    #   end
    def fragment x
      self.render_context.children.push x
    end
    alias :frag :fragment

    # Define the factory method.
    #
    # can be called like:
    #   tag 'content'
    #   tag { content }
    #   tag 'content', :attribute => 'value'
    #   tag(:attribute=>'value') do
    #     content
    #   end
    #   tag
    #   tag (:attribute => value)
    def self.define_element name, klass
      Rxhp::Scope.send(:define_method, name) do |*args, &block|
        # Yay for faking named parameters as a hash :p
        children = nil
        attributes = {}
        args.each do |arg|
          if arg.is_a?(Hash)
            attributes = arg
          else
            children ||= []
            children.push arg
          end
        end

        # Create the actual element
        element = klass.new(attributes)

        # Append the new element to the real parent - parent isn't defined
        # by scope, as:
        # html do
        #   # I have the same 'self' as...
        #   body do
        #     # ... here
        #   end
        # end
        context = self.render_context
        context.children.push element

        # Append non-block children
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
          # push element onto the render stack...
          self.sub_render(element) do
            # ... and call the block with that new stack
            result = block.call
            if result && result.is_a?(String)
              # Element children will have already been appended, given
              # their creation would run through this method themselves.
              element.children.push result
            end
          end
        end
        element
      end
    end
  end
end
