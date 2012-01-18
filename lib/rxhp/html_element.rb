require 'rxhp/element'

module Rxhp
  # Base class for 'real' elements that actually end up in the markup.
  #
  # For example, <span> is a subclass of this.
  #
  # To use:
  # 1. subclass
  # 2. define tag_name
  # 3. call Rxhp::Scope.define_element('foo', Foo) to register the class
  # ... or just add a define_tag line to html.rb.
  #
  # There's another two base classes for special types of html elements:
  # - HtmlSelfClosingElement - elements where in HTML, the closing tag is
  #   optional - for example, <p>, <li>, and <body>
  # - HtmlSingletonElement - not only is the closing tag optional, but
  #   child elements are forbidden - for example, <br> and <img>
  #
  # These can also be defined via Rxhp::Html#define_tag
  #
  # If you're making a custom element that's purely server-side (i.e. is
  # just composed of HTML elements), you want to subclass ComposableElement
  # instead.
  class HtmlElement < Element
    def tag_name
      raise NotImplementedError.new
    end

    # Render the element.
    #
    # Pays attention to the formatter type, doctype, pretty print options,
    # etc.
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

    # If we don't already have a render context, use this element as
    # the root.
    #
    # If we don't override this, all children would get assigned to a
    # throwaway Rxhp::Fragment - the root 'real' element needs to take
    # them.
    #
    # See Rxhp::Renderer for a general explanation of this.
    def render_context
      render_stack.last || self
    end

    # Override to increase the depth count for the sake of pretty printing
    def render_children options = {}
      child_options = options.dup
      child_options[:depth] += 1
      super child_options
    end

    protected

    # html-escape a string, paying attention to indentation too.
    def render_string string, options
      escaped = html_escape(string)
      if options[:pretty]
        indent = ' ' * (options[:indent] * options[:depth])
        indent + escaped + "\n"
      else 
        escaped
      end
    end

    # Render the opening tag.
    #
    # Considers:
    #  - attributes
    #  - XHTML or HTML?
    #  - are there any children?
    #
    # #render_close_tag assumes that this will not leave a tag open in XHTML
    # unless there are children.
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

    # Render the closing tag.
    #
    # Assumes that #render_open_tag would have made a self-closing tag if
    # appropriate.
    #
    # This is overriden in:
    # - HtmlSingletonElement: never any children, so never a closing tag
    # - HtmlSelfClosingElement: calls this, /unless/ tiny html output is
    #   selected, in which case the closing tag is skipped.
    def render_close_tag options
      if options[:format] != Rxhp::XHTML_FORMAT || children?
        '</' + tag_name + '>'
      end
    end

    # Don't pull in ActiveSupport just for this...
    def html_escape s
      s.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;').gsub('"','&quot;')
    end
  end
end
