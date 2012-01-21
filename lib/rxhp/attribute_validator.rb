require 'rxhp/error'

module Rxhp
  module AttributeValidator
    class ValidationError < Rxhp::ScriptError
    end

    class UnacceptableAttributeError < ValidationError
      attr_reader :element, :attribute, :value
      def initialize element, attribute, value
        @element, @attribute, @value = element, attribute, value
        super "Class #{element.class.name} does not support #{attribute}=#{value.inspect}"
      end
    end

    class MissingRequiredAttributeError < ValidationError
      attr_reader :element, :attribute
      def initialize element, attribute
        @element, @attribute = element, attribute
        super "Element #{element.inspect} is missing required attributes: #{attribute.inspect}"
      end
    end

    def valid_attributes?
      begin
        self.validate_attributes!
        true
      rescue ValidationError
        false
      end
    end

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
        matched = self.class.attribute_matchers.any? do |matcher|
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
          name_match = match?(name_matcher, name, nil)
          value_match = match?(value_matcher, value, nil)
          name_match && value_match
        end
      when Symbol
        matcher.to_s.gsub('_', '-') == name
      else
        matcher === name
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      class << klass
        attr_accessor :attribute_matchers, :required_attributes
        def accept_attributes matcher
          attribute_matchers.push matcher
        end
        alias :accept_attribute :accept_attributes

        def require_attributes matcher
          accept_attributes matcher
          required_attributes.push matcher
        end
        alias :require_attribute :require_attributes

        def accept_all_attributes
          attribute_matches.push Object
        end
      end

      klass.attribute_matchers = []
      klass.required_attributes = []
    end

    def self.inherited(subklass)
      subklass.class_eval do
        include Rxhp::AttributeValidator
      end
      subklass.attribute_matchers = subklass.superclass.attribute_matchers.dup
      subklass.required_attributes = subklass.superclass.required_attributes.dup
    end

    module ClassMethods
      def inherited(subklass)
        Rxhp::AttributeValidator.inherited(subklass)
      end

    end
  end
end
