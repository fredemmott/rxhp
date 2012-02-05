require 'rxhp/fragment'
require 'rxhp/html'

module Rxhp
  # Subclass of fragment that is able to render strings.
  #
  # This is available as +Rxhp::Html#fragment+, +#frag+, and +#text+.
  class HtmlFragment < Fragment
    def render_string string, options = {}
      escaped = Rxhp::Html.escape(string)
      if options[:pretty]
        indent = ' ' * (options[:indent] * options[:depth])
        indent + escaped + "\n"
      else
        escaped
      end
    end
  end
end
