require 'rxhp/html_element'
require 'rxhp/html_self_closing_element'
require 'rxhp/html_singleton_element'

require 'rxhp/data/html/attributes'

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
    TAGS = {
      :a => {
        :attributes => [
          HREF_ATTRIBUTE,
          MEDIA_ATTRIBUTE,
          REL_ATTRIBUTE,
          {
            :target => String,
            :hreflang => String,
            :type => String,
          },
        ],
      },
      :abbr => {},
      :acronym => {},
      :address => {},
      :applet => {},
      :area => {
        :is_a => HtmlSingletonElement,
        :attributes => [
          HREF_ATTRIBUTE,
          REL_ATTRIBUTE,
          MEDIA_ATTRIBUTE,
          {
            :alt => String,
            :coords => INTEGER_LIST,
            :shape => %w(circle default poly rect),
            :target => String,
            :media => String,
            :hreflang => String,
            :type => String,
          },
        ],
      },
      :article => {},
      :aside => {},
      :audio => {
        :attributes => [
          SRC_ATTRIBUTE,
          CROSSORIGIN_ATTRIBUTE,
          COMMON_MEDIA_ATTRIBUTES,
        ],
      },
      :b => {},
      :base => {
        :is_a => HtmlSingletonElement,
        :attributes => [
          HREF_ATTRIBUTE,
          { :target => String },
        ],
      },
      :basefont => {},
      :bdo => {},
      :bdi => {},
      :big => {},
      :blockquote => { :attributes => CITE_ATTRIBUTE },
      :body => {
        :is_a => HtmlSelfClosingElement,
        :attributes => %w[
          onafterprint
          onbeforeprint
          onbeforeunload
          onblur
          onerror
          onfocus
          onhashchange
          onload
          onmessage
          onoffline
          ononline
          onpagehide
          onpageshow
          onpopstate
          onresize
          onscroll
          onstorage
          onunload
        ],
      },
      :br => {:is_a => HtmlSingletonElement},
      :button => {
        :attributes => [
          FORM_ATTRIBUTES,
          {
            :autofocus => [true, false],
            :disabled => [true, false],
            :name => String,
            :value => Object,
            :type => %w[submit reset button],
          },
        ],
      },
      :canvas => {
        :attributes => DIMENSION_ATTRIBUTES,
      },
      :caption => {},
      :center => {},
      :cite => {},
      :code => {},
      :col => {
        :is_a => HtmlSingletonElement,
        :attributes => SPAN_ATTRIBUTE,
      },
      :colgroup => {
        :is_a => HtmlSelfClosingElement,
        :attributes => SPAN_ATTRIBUTE,
      },
      :command => {
        :is_a => HtmlSingletonElement,
        :attributes => {
          :type => %w[command checkbox radio],
          :label => String,
          :icon => [String, URI],
          :disabled => [true, false],
          :radiogroup => String,
        },
      },
      :datalist => {},
      :dd => {:is_a => HtmlSelfClosingElement},
      :del => {
        :attributes => [
          CITE_ATTRIBUTE,
          DATETIME_ATTRIBUTE,
        ],
      },
      :details => { :attributes => { :open => [true, false] } },
      :dfn => {},
      :dir => {},
      :div => {},
      :dl => {},
      :dt => {:is_a => HtmlSelfClosingElement},
      :em => {},
      :embed => {
        :is_a => HtmlSingletonElement,
        :attributes => {Object => Object }, # anything :/
      },
      :fieldset => {
        :attributes => {
          :disabled => [true, false],
          :form => String,
          :name => String,
        },
      },
      :figcaption => {},
      :figure => {},
      :font => {},
      :footer => {},
      :form => {
        :attributes => [
          AUTOCOMPLETE_ATTRIBUTE,
          {
            'accept-charset' => String,
            :action => [String, URI],
            :enctype => ENC_TYPES,
            :method => ['get', 'post'],
            :name => String,
            :novalidate => [true, false],
            :target => String,
          },
        ],
      },
      :frame => {},
      :frameset => {},
      :h1 => {},
      :h2 => {},
      :h3 => {},
      :h4 => {},
      :h5 => {},
      :h6 => {},
      :head => {:is_a => HtmlSelfClosingElement},
      :header => {},
      :hgroup => {},
      :hr => {:is_a => HtmlSingletonElement},
      :html => {:require => 'rxhp/tags/html_tag'},
      :i => {},
      :iframe => {
        :attributes => [
          SRC_ATTRIBUTE,
          DIMENSION_ATTRIBUTES,
          {
            :srcdoc => String,
            :name => String,
            :sandbox => ['', token_list(%w[
              allow-forms
              allow-same-origin
              allow-scripts
              allow-top-navigation
            ])],
            :seamless => [true, false],
          },
        ],
      },
      :img => {
        :is_a => HtmlSingletonElement,
        :attributes => [
          SRC_ATTRIBUTE,
          DIMENSION_ATTRIBUTES,
          CROSSORIGIN_ATTRIBUTE,
          {
            :alt => String,
            :usemap => String,
            :ismap => [true, false],
          },
        ],
      },
      :input => {
        :is_a => HtmlSingletonElement,
        :attributes => [
          AUTOCOMPLETE_ATTRIBUTE,
          DIMENSION_ATTRIBUTES,
          SRC_ATTRIBUTE,
          FORM_ATTRIBUTES,
          {
            :accept => String,
            :alt => String,
            :autofocus => [true, false],
            :checked => [true, false],
            :dirname => String,
            :disabled => [true, false],
            :list => String,
            :max => [Numeric, String],
            :maxlength => Integer,
            :min => [Numeric, String],
            :multiple => [true, false],
            :name => String,
            :pattern => String, # ECMAScript RE != RegExp.to_s
            :placeholder => String,
            :required => [true, false],
            :step => [Numeric, String],
            :value => Object,
            :type => %w[
              hidden
              text
              search
              tel
              url
              email
              password
              datetime
              date
              month
              week
              time
              datetime-local
              number
              range
              color
              checkbox
              radio
              file
              submit
              image
              reset
              button
            ],
          },
        ],
      },
      :ins => {
        :attributes => [
          CITE_ATTRIBUTE,
          DATETIME_ATTRIBUTE,
        ],
      },
      :isindex => {},
      :kbd => {},
      :keygen => {
        :is_a => HtmlSingletonElement,
        :attributes => {
          :autofocus => [true, false],
          :challenge => String,
          :disabled => [true, false],
          :form => String,
          :keytype => 'rsa',
          :name => String,
        },
      },
      :label => {
        :attributes => {
          :form => String,
          :for => String,
        },
      },
      :legend => {},
      :li => {
        :is_a => HtmlSelfClosingElement,
        :attributes => {
          :value => Integer,
        },
      },
      :link => {
        :is_a => HtmlSingletonElement,
        :attributes => [
          HREF_ATTRIBUTE,
          REL_ATTRIBUTE,
          {
            :href_lang => String,
            :type => String,
            :sizes => [
              'any',
              /^\d+x\d+( \d+x\d+)*/,
            ],
          },
        ],
      },
      :map => { :attributes => { :name => String } },
      :mark => {},
      :menu => {
        :attributes => {
          :type => ['context', 'toolbar'],
          :label => String,
        },
      },
      :meta => {
        :is_a => HtmlSingletonElement,
        :attributes => {
          :name => String,
          :content => String,
          :charset => String,
          'http-equiv' => %w(content-language content-type default-style refresh set-cookie),
        },
      },
      :meter => {
        :attributes => {
          %w[value min max low high optimum] => [String, Numeric],
        },
      },
      :nav => {},
      :noframes => {},
      :noscript => {},
      :object => {
        :attributes => [
          DIMENSION_ATTRIBUTES,
          {
            :data => [String, URI],
            :type => String,
            :typemustmatch => [true, false],
            :name => String,
            :usemap => String,
            :form => String,
          },
        ],
      },
      :ol => {
        :attributes => {
          :reversed => [true, false],
          :start => Integer,
          :type => %w{1 a A i I},
        },
      },
      :optgroup => {
        :is_a => HtmlSelfClosingElement,
        :attributes => {
          :disabled => [true, false],
          :label => String,
        },
      },
      :option => {
        :is_a => HtmlSelfClosingElement,
        :attributes => {
          :disabled => [true, false],
          :label => String,
          :selected => [true, false],
          :value => Object,
        },
      },
      :output => {
        :attributes => {
          :for => String,
          :form => String,
          :name => String,
        },
      },
      :p => {:is_a => HtmlSelfClosingElement},
      :param => {
        :is_a => HtmlSingletonElement,
        :attributes => {
          :name => String,
          :value => String,
        },
      },
      :pre => {},
      :progress => {
        :attributes => {
          :value => Object,
          :max => [Numeric, String],
        },
      },
      :rb => {},
      :rt => {},
      :ruby => {},
      :q => { :attributes => CITE_ATTRIBUTE },
      :s => {},
      :samp => {},
      :script => {
        :attributes => [
          SRC_ATTRIBUTE,
          {
            :async => [true, false],
            :defer => [true, false],
            :type => String,
            :charset => String,
          },
        ],
      },
      :section => {},
      :select => {
        :attributes => {
          :autofocus => [true, false],
          :disabled => [true, false],
          :form => String,
          :multiple => [true, false],
          :name => String,
          :required => [true, false],
          :size => Integer,
        },
      },
      :small => {},
      :source => {
        :is_a => HtmlSingletonElement,
        :attributes => [
          SRC_ATTRIBUTE,
          MEDIA_ATTRIBUTE,
          { :type => String },
        ],
      },
      :span => {},
      :strike => {},
      :strong => {},
      :style => {
        :attributes => [
          MEDIA_ATTRIBUTE,
          {
            :type => String,
            :scoped => [true, false],
          },
        ],
      },
      :sub => {},
      :summary => {},
      :sup => {},
      :table => { :attributes => {:border => '1' } },
      :tbody => {:is_a => HtmlSelfClosingElement},
      :td => {
        :is_a => HtmlSelfClosingElement,
        :attributes => TABLE_CELL_ATTRIBUTES,
      },
      :textarea => {
        :attributes => {
          :autofocus => [true, false],
          :cols => Integer,
          :dirname => String,
          :disabled => [true, false],
          :form => String,
          :maxlength => Integer,
          :name => String,
          :placeholder => String,
          :readonly => [true, false],
          :required => [true, false],
          :rows => Integer,
          :wrap => ['soft', 'hard'],
        },
      },
      :tfoot => {:is_a => HtmlSelfClosingElement},
      :th => {
        :is_a => HtmlSelfClosingElement,
        :attributes => [
          TABLE_CELL_ATTRIBUTES,
          {
            :scope => %w(row col rowgroup colgroup),
          },
        ],
      },
      :thead => {:is_a => HtmlSelfClosingElement},
      :time => {
        :attributes => DATETIME_ATTRIBUTE,
      },
      :title => {},
      :tr => {:is_a => HtmlSelfClosingElement},
      :track => {
        :is_a => HtmlSingletonElement,
        :attributes => [
          SRC_ATTRIBUTE,
          {
            :kind => %w(subtitles captions descriptions chapters metadata),
            :srclang => String,
            :label => String,
            :default => [true, false],
          },
        ],
      },
      :tt => {},
      :u => {},
      :ul => {},
      :var => {},
      :video => {
        :attributes => [
          SRC_ATTRIBUTE,
          CROSSORIGIN_ATTRIBUTE,
          DIMENSION_ATTRIBUTES,
          COMMON_MEDIA_ATTRIBUTES,
          {
            :poster => [String, URI],
          },
        ],
      },
      :wbr => {:is_a => HtmlSingletonElement},
    }
  end
end
