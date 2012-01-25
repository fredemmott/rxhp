require 'rxhp/html_element'

module Rxhp
  # Base class for HTML elements where the closing tag is optional, but
  # there can still be children.
  #
  # For example, +</p>+ is optional in HTML, but required in XHTML.
  # This will change whether they're included or not based on the selected
  # render format.
  class HtmlSelfClosingElement < HtmlElement
    protected
    # Render a close tag if appropriate.
    #
    # The close tag is appropriate if we're outputting nice HTML, or XHTML.
    def render_close_tag options
      super if options[:format] != Rxhp::TINY_HTML_FORMAT
    end
  end
end
