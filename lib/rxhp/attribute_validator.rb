require 'rxhp/error'

module Rxhp
  module AttributeValidator
    class ValidationError < Rxhp::ScriptError
      attr_reader :klass, :attribute, :value
      def initialize klass, attribute, value
        @klass, @attribute, @value = klass, attribute, value
        super "Invalid attribute #{attribute}=#{value}"
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
      self.attributes.all? do |key, value|
        key = key.to_s
        matched = self.class.attribute_matchers.any? do |matcher|
          Rxhp::AttributeValidator.match? matcher, key, value
        end

        if !matched
          raise ValidationError.new(self.class, key, value)
        end
      end
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
        matcher.to_s == name
      else
        matcher === name
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      class << klass
        attr_accessor :attribute_matchers

        def accept_attributes matcher
          attribute_matchers.push matcher
        end

        def accept_all_attributes
          attribute_matches.push Object
        end
      end

      klass.attribute_matchers = []
    end

    module ClassMethods
      def inherited(subklass)
        subklass.class_eval do
          include Rxhp::AttributeValidator
        end
        subklass.attribute_matchers = subklass.superclass.attribute_matchers.dup
      end
    end
  end
end
