require 'continuation' unless RUBY_VERSION =~ /^1\.8\./
module Rxhp
  autoload :Fragment, 'rxhp/fragment'
  # A place for factory methods to be defined.
  #
  # These are methods like +Rxhp::Scope#h1+ which creates an instance of
  # +Rxhp::Html::H1+.
  #
  # The actual HTML classes are defined in rxhp/html.rb
  #
  module Scope
    # Helper function to append a child to the current context.
    #
    # @example Here's one I made earlier
    #   inner = body { 'hi' }
    #   html do
    #     fragment inner
    #   end
    #
    # @example Multiple +String+ children
    #   p do
    #     text 'foo'
    #     text 'bar'
    #   end
    def fragment x
      Rxhp::Scope.current.children.push x
    end
    alias :frag :fragment
    alias :text :fragment

    # The element nesting scope.
    #
    # @example
    #   Rxhp::Scope.current.should be_a Rxhp::Fragment
    #   html.do
    #     Rxhp::Scope.current.should be_a Rxhp::Html::Html
    #     body do
    #       Rxhp::Scope.current.should be_a Rxhp::Html::Body
    #     end
    #   end
    def self.current
      callcc do |cc|
        begin
          throw(:rxhp_parent, cc)
        rescue NameError, ArgumentError
          Rxhp::Fragment.new
        end
      end
    end

    # Set the value of {#current} for a block, and call it.
    #
    # Used by {#define_element}
    def self.with_parent parent, &block
      # push element onto the render stack...
      cc = catch(:rxhp_parent) do
        # ... and call the block with that new stack
        block.call
        nil
      end
      cc.call(parent) if cc
    end

    # Define a factory method that takes a block, with a scope.
    #
    # @param [String] name is the name of the method to define
    # @param [Class] klass is the {Element} subclass to construct
    # @param [Module] namespace is where to define the method
    #
    # @example
    #   define_element tag, Tag
    #   tag
    #   tag 'content'
    #   tag(:attribute => value)
    #   tag('content', :attribute => 'value')
    #   tag(:attribute => 'value') do
    #     text 'content'
    #   end
    def self.define_element name, klass, namespace = Kernel
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
          end
          element.validate! if element.respond_to?(:validate!)
          nil
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
  end
end
