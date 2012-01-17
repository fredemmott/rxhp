require 'rxhp/element'

module Rxhp
  class HtmlElement < Element
    def render options = {}
      options = fill_options(options) 

      open = render_open_tag(options)
      inner = render_children(options)
      close = render_close_tag(options)

      if options[:pretty]
        indent = ' ' * (options[:indent] * options[:depth])
        out = "%s%s\n" % [indent, open]
        out += inner if inner
        out += "%s%s\n" % [indent, close] if close && !close.empty?
        out
      else
        out = open
        out += inner if inner
        out += close if close
        out
      end
    end

    def render_context
      render_stack.last || self
    end

    def render_children options = {}
      child_options = options.dup
      child_options[:depth] += 1
      super child_options
    end

    protected

    def render_string string, options
      escaped = html_escape(string)
      if options[:pretty]
        indent = ' ' * (options[:indent] * options[:depth])
        indent + escaped + "\n"
      else 
        escaped
      end
    end

    def render_open_tag options
      out = '<' + tag_name
      unless attributes.empty?
        attributes.each do |name,value|
          out += ' ' + name.to_s + '="' + html_escape(value) + '"'
        end
      end

      if options[:format] == Rxhp::XHTML_FORMAT && !children?
        out + ' />'
      else
        out + '>'
      end
    end

    def render_close_tag options
      if options[:format] != Rxhp::XHTML_FORMAT || children?
        '</' + tag_name + '>'
      end
    end

    def html_escape s
      s.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;').gsub('"','&quot;')
    end
  end
end
