require 'rxhp/html_element'
require 'rxhp/error'

module Rxhp
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
