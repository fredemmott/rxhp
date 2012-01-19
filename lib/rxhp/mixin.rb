require 'rxhp/scope'

module Rxhp
  # Mix this in to your classes if you want to call Rxhp-element factory
  # methods.
  module Mixin
    include Rxhp::Scope
  end
end
