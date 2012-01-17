require 'rxhp/html_element'

module Rxhp
  class HtmlSelfClosingElement < HtmlElement
    protected
    def render_close_tag options
      super if options[:format] != Rxhp::TINY_HTML_FORMAT
    end
  end
end
