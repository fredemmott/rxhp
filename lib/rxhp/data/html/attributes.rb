require 'uri'

module Rxhp
  module Html
    # Given +['foo', 'bar', 'baz']+, match:
    # * +'foo'+
    # * +'bar baz'+
    # * +'foo bar baz'+
    # etc.
    def self.token_list tokens
      token = tokens.join('|')
      /^#{token}( (#{token}) )*$/
    end

    # All the non-javascript attributes shared by every HTML element.
    GLOBAL_ATTRIBUTES = {
      /^data-[^:]+$/ => Object,

      :accesskey => String,
      :class => String,
      :contenteditable => %w'true false inherit',
      :contextmenu => String,
      :dir => %w'ltr rtl auto',
      :draggable => %w'true false',
      :dropzone => String,
      :hidden => [true, false],
      :id => /^[^ ]+$/,
      :lang => String,
      :spellcheck => %w'true false',
      :style => String,
      :tabindex => Integer,
      :title => String,
    }

    # Every HTML element has these
    GLOBAL_EVENT_HANDLERS = {
      :onabort => String,
      :onblur => String,
      :oncanplay => String,
      :oncanplaythrough => String,
      :onchange => String,
      :onclick => String,
      :oncontextmenu => String,
      :oncuechange => String,
      :ondblclick => String,
      :ondrag => String,
      :ondragend => String,
      :ondragenter => String,
      :ondragleave => String,
      :ondragover => String,
      :ondragstart => String,
      :ondrop => String,
      :ondurationchange => String,
      :onemptied => String,
      :onended => String,
      :onerror => String,
      :onfocus => String,
      :oninput => String,
      :oninvalid => String,
      :onkeydown => String,
      :onkeypress => String,
      :onkeyup => String,
      :onload => String,
      :onloadeddata => String,
      :onloadedmetadata => String,
      :onloadstart => String,
      :onmousedown => String,
      :onmousemove => String,
      :onmouseout => String,
      :onmouseover => String,
      :onmouseup => String,
      :onmousewheel => String,
      :onpause => String,
      :onplay => String,
      :onplaying => String,
      :onprogress => String,
      :onratechange => String,
      :onreset => String,
      :onscroll => String,
      :onseeked => String,
      :onseeking => String,
      :onselect => String,
      :onshow => String,
      :onstalled => String,
      :onsubmit => String,
      :onsuspend => String,
      :ontimeupdate => String,
      :onvolumechange => String,
      :onwaiting => String,
    }

    # Specific attributes used by multiple elements
    HREF_ATTRIBUTE = { :href => [String, URI] }
    MEDIA_ATTRIBUTE = { :media => String }
    REL_ATTRIBUTE = {
      :rel => Rxhp::Html.token_list(%w[
        alternate
        author
        bookmark
        help
        icon
        license
        next
        nofollow
        noreferrer
        prefetch
        prev
        search
        stylesheet
        tag
      ]),
    }
    DATETIME_ATTRIBUTE = { :datetime => String }
    CITE_ATTRIBUTE = { :cite => [String, URI] }
    SRC_ATTRIBUTE = { :src => [String, URI] }
    DIMENSION_ATTRIBUTES = {
      :width => String,
      :height => String,
    }
    CROSSORIGIN_ATTRIBUTE = {
      :crossorigin => /^(anonymous|use-credentials)$/,
    }
    COMMON_MEDIA_ATTRIBUTES = {
      :preload => /^(none|metadata|auto)/,
      :autoplay => [true, false],
      :mediagroup => String,
      :loop => [true, false],
      :muted => [true, false],
      :controls => [true, false],
    }
    SPAN_ATTRIBUTE = { :span => Integer }
    TABLE_CELL_ATTRIBUTES = {
      :colspan => Integer,
      :rowspan => Integer,
      :headers => String,
    },
    AUTOCOMPLETE_ATTRIBUTE = { :autocomplete => ['on', 'off'] }

    ENC_TYPES = %w[
      application/x-www-form-urlencoded
      multipart/form-data
      text/plain
    ]
    INTEGER_LIST = /^\d+(,\d+)*$/
    FORM_ATTRIBUTES = {
      :form => String,
      :formaction => [String, URI],
      :formenctype => ENC_TYPES,
      :formmethod => ['get', 'post'],
      :formnovalidate => [true, false],
      :formtarget => String,
    }
  end
end
