require 'rxhp/element'
require 'rxhp/attribute_validator'

require 'rxhp/data/html/attributes'

module Rxhp
  # Base class for 'real' elements that actually end up in the markup.
  #
  # For example, <span> is a subclass of this.
  #
  # To use:
  # 1. subclass
  # 2. define {#tag_name}
  # 3. call +Rxhp::Scope.define_element('foo', Foo, MyModule)+ to register
  #    the class
  # ... or just add a +define_tag+ line to html.rb.
  #
  # There's another two base classes for special types of html elements:
  # {HtmlSelfClosingElement}::: elements where in HTML, the closing tag is
  #                             optional - for example, <p> and <li>
  # {HtmlSingletonElement}::: not only is the closing tag optional, but
  #                           child elements are forbidden - for example,
  #                           <br> and <img>
  #
  # These can also be defined via {Rxhp::Html#define_tag}
  #
  # If you're making a custom element that's purely server-side (i.e. is
  # just composed of HTML elements), you want to subclass
  # {ComposableElement} instead.
  class HtmlElement < Element
    include Rxhp::AttributeValidator
    accept_attributes Rxhp::Html::GLOBAL_ATTRIBUTES
    accept_attributes Rxhp::Html::GLOBAL_EVENT_HANDLERS

    # Literal string to include in render output.
    #
    # For example, +'html'+ will lead to +'<html>...</html>'+.
    def tag_name
      raise NotImplementedError.new
    end

    # Check that the element usage does nto have detectable errors.
    #
    # At the moment, this just checks for attribute correctness.
    def validate!
      super
      validate_attributes!
    end

    # Render the element.
    #
    # Pays attention to the formatter type, doctype, pretty print options,
    # etc. See {Element#render} for options.
    def render options = {}
      validate!
      options = fill_options(options)

      open = render_open_tag(options)
      inner = render_children(options)
      close = render_close_tag(options)

      if options[:pretty]
        indent = ' ' * (options[:indent] * options[:depth])
        out = indent.dup
        out << open << "\n"
        out << inner if inner
        out << indent << close << "\n" if close && !close.empty?
        out
      else
        out = open
        out << inner if inner
        out << close if close
        out
      end
    end

    # Render child elements.
    #
    # Increases the depth count for the sake of pretty printing.
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
          name = name.to_s.gsub('_', '-') if name.is_a? Symbol
          value = value.to_s.gsub('_', '-') if value.is_a? Symbol

          case value
          when false
            next
          when true
            if options[:format] == Rxhp::XHTML_FORMAT
              out += ' ' + name + '="' + name + '"'
            else
              out += ' ' + name
            end
          else
            out += ' ' + name.to_s + '="' + html_escape(value.to_s) + '"'
          end
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
      Rxhp::Html.escape(s)
    end
  end
end
