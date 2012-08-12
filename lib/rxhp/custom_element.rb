require 'rxhp/attribute_validator'
require 'rxhp/element'

module Rxhp
  class CustomElement < Rxhp::Element
    include Rxhp::AttributeValidator

    # Check that there are no detectable problems, such as invalid
    # attributes.
    def validate!
      super
      validate_attributes!
    end
  end
end
