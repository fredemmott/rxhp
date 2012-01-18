#!/usr/bin/env ruby
$LOAD_PATH.push './lib'

require 'rxhp/mixin'
require 'rxhp/composable_element'
require 'rxhp/html'

# This actually defines a new kind of element, that is composed of other
# elements - it has no real rendering itself.
class HelloWorldBody < Rxhp::ComposableElement
  def compose
    body do
      p 'Hello,'
      br
      yield # Call the children, and embed them here
      p(:class => 'bonus') do
        "& <some escaping too>"
      end
    end
  end
end

# Well, you could just create an instance of it (or any other element)
# directly:
#  foo = HelloWorldBody.new

# But that would be boring. Let's use a mixin instead (and in the process,
# show that we really did just create a tag, and make it have the missing
# html tag
class Foo
  include Rxhp::Mixin
  def wrap_a_body
    html do
      hello_world_body do
        'world.'
      end
    end
  end
end

foo = Foo.new.wrap_a_body
puts '===== HTML mode ====='
puts foo.render
puts '===== XHTML mode ====='
puts foo.render(
  :format => Rxhp::XHTML_FORMAT,
  :doctype => Rxhp::XHTML_1_0_STRICT
)
puts '===== Tiny HTML mode ====='
puts foo.render(
  :format => Rxhp::TINY_HTML_FORMAT,
  :pretty => false,
  :skip_doctype => true
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
