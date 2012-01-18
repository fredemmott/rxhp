require 'rxhp/html_element'
require 'rxhp/html_self_closing_element'
require 'rxhp/html_singleton_element'
require 'rxhp/scope'

module Rxhp
  # Definitions of all standard HTML 4.01 and HTML 5 elements.
  #
  # All the classes are created when this file is loaded, regardless
  # of usage.
  #
  # There are three common superclasses:
  # - HtmlElement - standard elements
  # - HtmlSelfClosingElement - elements where in HTML, the closing tag is
  #   optional - for example, <p>, <li>, and <body>
  # - HtmlSingletonElement - not only is the closing tag optional, but
  #   child elements are forbidden - for example, <br> and <img>
  #
  # 'Special' classes are defined in rxhp/tags/ - for example, the HTML
  # element in Rxhp is defined to add a doctype, depending on the formatter
  # settings.
  module Html
    # Create a 'Tag' class representing the element, and call
    # Rxhp::Scope#define_element to register the 'tag' method.
    def self.define_tag tag, parent = HtmlElement
      klass_name = tag.to_s.dup
      klass_name[0] = klass_name[0,1].upcase
      klass = Class.new(parent)
      klass.send(:define_method, :tag_name) { tag.to_s }

      Rxhp::Html.const_set(klass_name, klass)

      Rxhp::Scope.define_element tag, klass
    end

    define_tag :abbr
    define_tag :acronym
    define_tag :address
    define_tag :applet
    define_tag :area, HtmlSingletonElement
    define_tag :article
    define_tag :aside
    define_tag :audio
    define_tag :b
    define_tag :base, HtmlSingletonElement
    define_tag :basefont
    define_tag :bdo
    define_tag :bdi
    define_tag :big
    define_tag :blockquote
    define_tag :body, HtmlSelfClosingElement
    define_tag :br, HtmlSingletonElement
    define_tag :button
    define_tag :canvas
    define_tag :caption
    define_tag :center
    define_tag :cite
    define_tag :code
    define_tag :col, HtmlSingletonElement
    define_tag :colgroup, HtmlSelfClosingElement
    define_tag :command, HtmlSingletonElement
    define_tag :datalist
    define_tag :dd, HtmlSelfClosingElement
    define_tag :del
    define_tag :details
    define_tag :dfn
    define_tag :dir
    define_tag :div
    define_tag :dl
    define_tag :dt, HtmlSelfClosingElement
    define_tag :em
    define_tag :embed, HtmlSingletonElement
    define_tag :fieldset
    define_tag :figcaption
    define_tag :figure
    define_tag :font
    define_tag :footer
    define_tag :form
    define_tag :frame
    define_tag :frameset
    define_tag :h1
    define_tag :h2
    define_tag :h3
    define_tag :h4
    define_tag :h5
    define_tag :h6
    define_tag :head, HtmlSelfClosingElement
    define_tag :header
    define_tag :hgroup
    define_tag :hr, HtmlSingletonElement
    require 'rxhp/tags/html_tag.rb'
    define_tag :i
    define_tag :iframe
    define_tag :img, HtmlSingletonElement
    define_tag :input, HtmlSingletonElement
    define_tag :ins
    define_tag :isindex
    define_tag :kbd
    define_tag :keygen, HtmlSingletonElement
    define_tag :label
    define_tag :legend
    define_tag :li, HtmlSelfClosingElement
    define_tag :link, HtmlSingletonElement
    define_tag :map
    define_tag :mark
    define_tag :menu
    define_tag :meta, HtmlSingletonElement
    define_tag :meter
    define_tag :nav
    define_tag :noframes
    define_tag :noscript
    define_tag :object
    define_tag :ol
    define_tag :optgroup, HtmlSelfClosingElement
    define_tag :option, HtmlSelfClosingElement
    define_tag :output
    define_tag :p, HtmlSelfClosingElement
    define_tag :param, HtmlSingletonElement
    define_tag :pre
    define_tag :progress
    define_tag :rb
    define_tag :rt
    define_tag :ruby
    define_tag :q
    define_tag :s
    define_tag :samp
    define_tag :script
    define_tag :section
    define_tag :select
    define_tag :small
    define_tag :source, HtmlSingletonElement
    define_tag :span
    define_tag :strike
    define_tag :strong
    define_tag :style
    define_tag :sub
    define_tag :summary
    define_tag :sup
    define_tag :table
    define_tag :tbody, HtmlSelfClosingElement
    define_tag :td, HtmlSelfClosingElement
    define_tag :textarea
    define_tag :tfoot, HtmlSelfClosingElement
    define_tag :th, HtmlSelfClosingElement
    define_tag :thead, HtmlSelfClosingElement
    define_tag :time
    define_tag :title
    define_tag :tr, HtmlSelfClosingElement
    define_tag :track, HtmlSingletonElement
    define_tag :tt
    define_tag :u
    define_tag :ul
    define_tag :var
    define_tag :video
    define_tag :wbr, HtmlSingletonElement
  end
end
