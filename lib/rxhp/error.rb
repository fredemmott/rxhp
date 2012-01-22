module Rxhp
  class Error < ::StandardError
  end

  class ScriptError < ::ScriptError
  end

  class ValidationError < Rxhp::ScriptError
  end
end
