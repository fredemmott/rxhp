module Rxhp
  autoload :Fragment, 'rxhp/fragment'
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
      Rxhp::Scope.current.children.push x
    end
    alias :frag :fragment
    alias :text :fragment

    def self.current
      self.stack.last || Rxhp::Fragment.new
    end

    def self.with_parent parent
      result = nil
      begin
        self.stack.push parent
        result = yield
      ensure
        self.stack.pop
      end
      result
    end

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
    def self.define_element name, klass, namespace
      impl = Proc.new do |*args, &block|
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
        Rxhp::Scope.current.children.push element

        # Append non-block children
        if children
          children.each do |child|
            element.children.push child
          end
        end

        if block
          Rxhp::Scope.with_parent(element) do
            if block.call.is_a? String
              raise Rxhp::ScriptError.new(
                "In a block, use the 'text' method to include Strings"
              )
            end
            nil
          end
        end
        element
      end

      # Instance method if mixed in.
      #
      # Usage:
      #  include Rxhp::Html
      #  html do
      #    ...
      #  end
      namespace.send(:define_method, name, impl)
      # Class method for fully-qualified.
      #
      # Usage:
      #  Rxhp::Html.html do
      #    ...
      #  end
      (class <<namespace; self; end).send(:define_method, name, impl)
    end

    private

    def self.stack
      Thread.current[:rxhp_scope_stack] ||= []
    end
  end
end
