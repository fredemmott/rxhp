module Rxhp
  # Render 'nice' HTML
  # @example
  #   <div><p>foo<br>bar</p></div>
  HTML_FORMAT = :html
  # Render ugly, but valid HTML
  # @example
  #  <div><p>foo<br>bar</div>
  TINY_HTML_FORMAT = :tiny_html
  # Render XHTML
  # @example
  #  <div><p>foo<br />bar</p></div>
  XHTML_FORMAT = :xhtml

  HTML_5 = "<!DOCTYPE html>\n"
  HTML_4_01_TRANSITIONAL = <<EOF
<!DOCTYPE HTML PUBLIC
  "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
EOF
  XHTML_1_0_STRICT = <<EOF
<!DOCTYPE html PUBLIC
  "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
EOF
end
