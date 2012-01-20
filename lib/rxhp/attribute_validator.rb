module Rxhp
  module AttributeValidator
    def validate_attributes
      self.attributes.all? do |key, value|
        self.class.attribute_matchers.any? do |matcher|
          Rxhp::AttributeValidator.match? matcher, key, value
        end
      end
    end

    def self.match? matcher, name, value
      case matcher
      when Array
        matcher.any? { |x| match? x, name, value }
      when Hash
        matcher.any? do |name_matcher, value_matcher|
          name_match = (name_matcher === name) || name_matcher.to_s == name
          name_match && (value_matcher === value)
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
