module Rxhp
  # Base class for runtime errors from Rxhp.
  #
  # Most exceptions in Rxhp are actually subclasses of {Rxhp::ScriptError},
  # which is not a subclass of this.
  class Error < ::StandardError
  end

  # Base class for script errors from Rxhp.
  class ScriptError < ::ScriptError
  end

  # Base class for element correctness errors from Rxhp.
  class ValidationError < Rxhp::ScriptError
  end
end
