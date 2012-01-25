require 'rxhp/html_self_closing_element'
require 'rxhp/scope'

module Rxhp
  module Html
    # Special-case for the <html> tag.
    #
    # This handles doctype rendering.
    class Html < HtmlSelfClosingElement
      def tag_name; 'html'; end

      protected
      def render_open_tag options
        if options[:skip_doctype]
          super
        else
          options[:doctype] + super
        end
      end
    end
  end
end

Rxhp::Scope.define_element('html', Rxhp::Html::Html, Rxhp::Html)
