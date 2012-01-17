#!/usr/bin/env ruby
$LOAD_PATH.push './lib'

require 'rxhp/mixin'
require 'rxhp/composable_element'
require 'rxhp/html'

class HelloWorld < Rxhp::ComposableElement
  def compose
    html do
      body do
        p 'Hello,'
        br
        p 'world.'
        p(:class => 'bonus') do
          "& <some escaping too>"
        end
      end
    end
  end
end

foo = HelloWorld.new
puts '===== HTML mode ====='
puts foo.render
puts '===== XHTML mode ====='
puts foo.render(
  :format => Rxhp::XHTML_FORMAT,
  :doctype => Rxhp::XHTML_1_0_STRICT,
)
puts '===== Tiny HTML mode ====='
puts foo.render(
  :format => Rxhp::TINY_HTML_FORMAT,
  :pretty => false,
  :skip_doctype => true,
)

# Also available as a mixin
class MyThing
  include Rxhp::Mixin
  def doSomething
    junk = html do
      'foo'
    end
    html do
      'bar'
    end
  end

  def render
    doSomething.render
  end
end
