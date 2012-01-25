require 'rxhp/error'

module Rxhp
  # Provide support for limiting or requiring attributes.
  #
  # Attributes can be:
  # * whitelisted (see {ClassMethods#accept_attributes})
  # * required (see {ClassMethods#require_attributes})
  #
  # Requiring an attribute automaticaly whitelists it.
  #
  # To use:
  # * +include+ this module
  # * whitelist/require attributes as appropriate
  # * call {#validate_attributes!} from wherever seems appropriate - such
  #   {Rxhp::Element#validate!}
  #
  # Subclasses will automatically have validated attributes, and will
  # copy the rules from their parent class. Additional attributes can be
  # accepted or required in subclasses without affecting the parent class.
  module AttributeValidator
    # Indicates that a provided attribute was not whitelisted.
    class UnacceptableAttributeError < ValidationError
      attr_reader :element, :attribute, :value
      def initialize element, attribute, value
        @element, @attribute, @value = element, attribute, value
        super "Class #{element.class.name} does not support #{attribute}=#{value.inspect}"
      end
    end

    # Indicates that a required attribute was not provided.
    class MissingRequiredAttributeError < ValidationError
      attr_reader :element, :attribute
      def initialize element, attribute
        @element, @attribute = element, attribute
        super "Element #{element.inspect} is missing required attributes: #{attribute.inspect}"
      end
    end

    # Whether or not the attributes are acceptable.
    #
    # If you need more details than just "it's invalid", call
    # {#validate_attributes!} instead and examine the exceptions it raises.
    #
    # @return whether or not the attributes are all whitelisted, and all
    #   required attributes are provided.
    def valid_attributes?
      begin
        self.validate_attributes!
        true
      rescue ValidationError
        false
      end
    end

    # Check if attributes are valid, and raise an exception if they're not.
    #
    # @raise {MissingRequiredAttributeError} if an attribute that is
    #   required was not provided.
    # @raise {UnacceptableAttributeError} if a non-whitelisted attribute
    #   was provided.
    # @return [true] if the attribute are all valid, and all required
    #   attributes are provided.
    def validate_attributes!
      # Check for required attributes
      self.class.required_attributes.each do |matcher|
        matched = self.attributes.any? do |key, value|
          key = key.to_s
          Rxhp::AttributeValidator.match? matcher, key, value
        end
        if !matched
          raise MissingRequiredAttributeError.new(self, matcher)
        end
      end

      # Check other attributes are acceptable
      return true if self.attributes.empty?
      self.attributes.each do |key, value|
        key = key.to_s
        matched = self.class.acceptable_attributes.any? do |matcher|
          Rxhp::AttributeValidator.match? matcher, key, value
        end

        if !matched
          raise UnacceptableAttributeError.new(self, key, value)
        end
      end
      true
    end

    def self.match? matcher, name, value
      case matcher
      when Array
        matcher.any? { |x| match? x, name, value }
      when Hash
        matcher.any? do |name_matcher, value_matcher|
          name_match = match_value?(name_matcher, name_from_symbol(name))
          if name_match
            match_value?(value_matcher, value)
          else
            false
          end
        end
      else
        match_value? matcher, name
      end
    end

    module ClassMethods
      attr_accessor :acceptable_attributes, :required_attributes
      # Accept all attributes matching the specified pattern.
      #
      # @param pattern can be a:
      #   +Symbol+:: must equal the attribute name after converting to a
      #              +String+, and replacing underscores with hyphens.
      #   +Object+:: must match the attribute name with +===+.
      #   +Array+:: the members must be a any of the above that matches the
      #             attribute name.
      #   +Hash+:: the key can be any of the above that matches the
      #            attribute name; the value is matched against the
      #            attribute value in the same way.
      # @example
      #   accept_attribute 'id'
      #   accept_attribute /^data-/
      #   accept_attributes ['href', 'src']
      #   accept_attributes ({ 'type' => ['checkbox', 'text', 'submit'] })
      def accept_attributes pattern
        acceptable_attributes.push pattern
      end
      alias :accept_attribute :accept_attributes

      # Require an attribute matching the specified pattern.
      #
      # @param pattern accepts the same values as {#accept_attributes}
      def require_attributes pattern
        accept_attributes pattern
        required_attributes.push pattern
      end
      alias :require_attribute :require_attributes

      # Accept any attributes whatsoever.
      def accept_all_attributes
        accept_attributes Object
      end

      private

      def inherited(subklass) # @Private @api
        Rxhp::AttributeValidator.inherited(subklass)
      end
    end

    private

    def self.name_from_symbol symbol
      symbol.to_s.gsub('_', '-')
    end

    def self.match_value? matcher, value
      if matcher == String
        return (value.is_a? String) || (value.is_a? Symbol)
      end

      case matcher
      when Array
        matcher.any? {|x| match_value?(x, value) }
      when Symbol
        name_from_symbol(matcher) == value
      else
        if value.is_a? Symbol
          (matcher === value.to_s) || (matcher === name_from_symbol(value))
        else
          matcher === value
        end
      end
    end

    # Include class methods, and initialize class variables.
    def self.included(klass)
      klass.extend(ClassMethods)

      klass.acceptable_attributes = []
      klass.required_attributes = []
    end

    # Make subclasses validated too.
    #
    # Their accept/require lists will be copied from their superclass, but
    # can be modified separately.
    def self.inherited(subklass)
      subklass.class_eval do
        include Rxhp::AttributeValidator
      end
      subklass.acceptable_attributes = subklass.superclass.acceptable_attributes.dup
      subklass.required_attributes = subklass.superclass.required_attributes.dup
    end
  end
end
