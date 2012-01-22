#!/usr/bin/env ruby
$LOAD_PATH.push './lib'

require 'rxhp'

# This actually defines a new kind of element, that is composed of other
# elements - it has no real rendering itself.
class HelloWorldBody < Rxhp::ComposableElement
  include Rxhp::Html # Import methods for every tag
  def compose
    body do
      p 'Hello,'
      br
      yield # Call the children, and embed them here
      p(:class => 'bonus') do
        text "& <some escaping too>"
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
  def wrap_a_body
    Rxhp::Html.html do # Don't import the methods, fully-qualify them
      hello_world_body do
        Rxhp::Html.text 'world.'
      end
    end
  end
end

$foo = Foo.new.wrap_a_body

if File.expand_path(__FILE__) == File.expand_path($0)
  puts '===== HTML mode ====='
  puts $foo.render
  puts '===== XHTML mode ====='
  puts $foo.render(
    :format => Rxhp::XHTML_FORMAT,
    :doctype => Rxhp::XHTML_1_0_STRICT
  )
  puts '===== Tiny HTML mode ====='
  puts $foo.render(
    :format => Rxhp::TINY_HTML_FORMAT,
    :pretty => false,
    :skip_doctype => true
  )
end
