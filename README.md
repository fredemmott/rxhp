I am no longer working with Ruby and this project is mostly unmaintained.

[API Documentation](http://rubydoc.info/github/fredemmott/rxhp/frames)

[![build status](https://secure.travis-ci.org/fredemmott/rxhp.png)](http://travis-ci.org/fredemmott/rxhp) [![dependency status](https://gemnasium.com/fredemmott/rxhp.png)](https://gemnasium.com/fredemmott/rxhp)

What is this?
=============

RXhp is a system for producing HTML or XHTML from Ruby.

```ruby
require 'rxhp'

H = Rxhp::Html
doc = H.html do
  H.body do
    H.p '<Hello, World>'
  end
end

puts doc.render
```

Gives you:

```html
<!DOCTYPE html>
<html>
  <body>
    <p>
      &lt;Hello, World&gt;
    </p>
  </body>
</html>
```

You can turn off the pretty printing, and optional closing tags (such as
\</p\>), or render XHTML instead.

Read hello.rb for a full example, or keep on reading for highlights.

Why should I use it?
====================

It's designed to make development and debugging faster - several features
help with this:

Custom Elements
---------------

Partials/helpers/sub-templates on steroids :) You _could_ do this:

```ruby
def make_my_widget foo, bar, baz=nil, awewaefa = nil
  Html.whatever do
    # ...
  end
end

body do
  fragment make_my_widget(*args)
end
```

That's not nice though :p How about this?

```ruby
module My
  class Widget < Rxhp::ComposableElement
    require_attributes { :foo => String, :bar => Object}
    accept_attributes { :awewaefa => /^(foo|bar|baz)$/ }

    def compose
      Html.whatever do
      end
    end
  end
end

body do
  My.widget(:foo => . ... )
end
```

Safety
------

If Rxhp::Html comes across a string, it escapes it - no exceptions.

* The default is secure - you dom't need to remember to call the escape
  function
* Applies to attributes too
* There is no raw text function - you'd need to subclass Rxhp::Element and
  reimplement render()

Attribute Validation
--------------------

This is fine:

```ruby
Rxhp::Html.html('data-herp' => 'derp')
```

This will raise an exception:

```ruby
Rxhp::Html.html('dtaa-herp' => 'derp') # sic
```

This is not a full validator - it's designed to catch trivial mistakes,
like typos, or misuse of boolean attributes:

```html
<!-- this is evaluated as checked = true - Rxhp will throw an exception if you try to do this -->
<input checked="false" />
```

Rxhp won't catch problems that aren't just pattern matching on name-value
pairs though - for example, this it won't spot the problem here:

```html
<ol>
  <li value="3">This is fine.</li>
</ol>

<ul>
  <li value="3">This isn't - no value attribute for li in ul please.</li>
</ul>
```

Singleton Validation
--------------------

You'll get exceptions for things like this:

```ruby
input(:type => :checkbox, :name => :foo) do
  text 'My checkbox label'
end
```

You probably meant:

```ruby
input(:type => :checkbox, :name => :foo)
label(:for => :foo) do
  text 'My checkbox label'
end
```

Produces HTML or XHTML
----------------------

Given this:

```ruby
html do
  body do
    div do
      p 'foo'
      input(:type => :checkbox, :checked => true)
    end
  end
end
```

Just by changing the render flags, you can get XHTML...

```html
<!DOCTYPE html PUBLIC
  "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <body>
    <div>
      <p>
        foo
      </p>
      <input type="checkbox" checked="checked" />
    </div>
  </body>
</html>
```

... HTML ...

```html
<!DOCTYPE html>
<html>
  <body>
    <div>
      <p>
        foo
      </p>
      <input type="checkbox" checked>
    </div>
  </body>
</html>
```

... or still, technically, HTML:

```html
<html><body><div><p>foo<input type="checkbox" checked></div>
```

How fast is it?
===============

Fast enough to be irrelevant in nearly any situation - see:

* [A trivial benchmark script](https://gist.github.com/1653689)
* [Output on a 2.67Ghz i7](https://gist.github.com/1653697)

That's < 0.5ms per render in that example. Some other template systems are
significantly faster, but this is still highly unlikely to be worrying in
any modern webapp.

Strings in Blocks
=================

These examples raise an exception, as it's not possible to intercept the
creation of string literals in Ruby:

```ruby
p do
  # This used to work, but now raises an exception...
  'foo'
end

p do
  # ... as this would silently ignore 'foo'. We'd need to know when the
  # string literal was created to add it, which isn't supported.
  'foo'
  'bar'
end
```

Instead, you need to do this:

```ruby
p 'foo' # if it's just string, use this handy shorcut...

p do
  # ... otherwise call 'text' - defined in Rxhp::Html, and available
  # directly in Rxhp::ComposableElement
  text 'foo'
  text 'bar'
end
```

How do the classes fit together?
================================

![class diagram](https://github.com/fredemmott/rxhp/raw/master/base-classes.png)

* Rxhp::Element is the root class - everything in an Rxhp tree is either
  an Element, a String, something implementing to\_s, or something that
  raises an error when you try :p
* Rxhp::HtmlElement is the direct superclass for most HTML elements - for
  example, Rxhp::Html::Title inherits from this.
* Rxhp::HtmlSingletonElement is the superclass for HTML elements that can
  not have children - for example, Rxhp::Html::Img inherits from this.
* Rxhp::HtmlSelfClosingElement is the superclass for HTML elements where
  you can optionally skip the closing tag, even if there are child
  elements, such as Rxhp::Html::P - this only acts differently to
  HtmlElement if the 'tiny HTML' renderer is used.
* Rxhp::ComposableElement is the base class for elements you make yourself,
  with no 'real' render - just composed of other Rxhp::Element subclasses
  and strings.
* Rxhp::Fragment is a bogus element - it just provides a container. It's
  rather similar to ComposableElement, but with less logic in it. It's used
  internally to provide a magic root element for trees.
