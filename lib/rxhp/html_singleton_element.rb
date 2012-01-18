require 'rxhp/html_element'
require 'rxhp/error'

module Rxhp
  # Superclass for all HTML elements that should never have children.
  #
  # This is enforced. Examples include '<br>', '<img>' etc
  #
  # There is never a close tag:
  # - in HTML it would be optional (and meaningless) anyway
  # - people don't expect to see them
  # - in XHTML, the opening tag will have been self closing.
  class HtmlSingletonElement < HtmlElement
    def render *args
      unless children.empty?
        raise Rxhp::ScriptError.new('Singleton element has children')
      end
      super *args
    end

    protected
    def render_close_tag options
      nil
    end
  end
end
