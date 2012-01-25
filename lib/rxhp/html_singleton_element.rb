require 'rxhp/html_element'
require 'rxhp/error'

module Rxhp
  # Superclass for all HTML elements that should never have children.
  #
  # This is enforced. Examples include +<br>+, +<img>+ etc
  #
  # There is never a close tag:
  # * in HTML it would be optional (and meaningless) anyway
  # * people don't expect to see them
  # * in XHTML, the opening tag will have been self closing.
  class HtmlSingletonElement < HtmlElement
    # Exception indicating that you gave a singleton element children.
    #
    # For example, +<br>foo</br>+ is invalid.
    class HasChildrenError < Rxhp::ValidationError
    end

    # Check that there are no child elements.
    #
    # @raises {HasChildrenError}
    def validate!
      super
      raise HasChildrenError.new unless children.empty?
    end

    protected
    # Skip the closing tag.
    #
    # In XHTML mode, {#render_open_tag} should have made it self-closing.
    def render_close_tag options
      nil
    end
  end
end
