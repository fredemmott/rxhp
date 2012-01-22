require 'spec_helper'

# Another 'brittle-but-worth-it' test

_DIR=File.expand_path(File.dirname(__FILE__))

load File.join(_DIR, '../../hello.rb')

describe 'hello.rb' do
  it 'renders the expected HTML output' do
    $foo.render.should == <<EOF
<!DOCTYPE html>
<html>
  <body>
    <p>
      Hello,
    </p>
    <br>
    world.
    <p class="bonus">
      &amp; &lt;some escaping too&gt;
    </p>
  </body>
</html>
EOF
  end

  it 'renders the expected XHTML output' do
    $foo.render(
      :format => Rxhp::XHTML_FORMAT,
      :doctype => Rxhp::XHTML_1_0_STRICT
    ).should == <<EOF
<!DOCTYPE html PUBLIC
  "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <body>
    <p>
      Hello,
    </p>
    <br />
    world.
    <p class="bonus">
      &amp; &lt;some escaping too&gt;
    </p>
  </body>
</html>
EOF
  end

  it 'renders the expected tiny HTML output' do
    $foo.render(
      :format => Rxhp::TINY_HTML_FORMAT,
      :pretty => false,
      :skip_doctype => true
    ).should == '<html><body><p>Hello,<br>world.<p class="bonus">&amp; &lt;some escaping too&gt;'
  end
end
