[![build status](https://secure.travis-ci.org/fredemmott/rxhp.png)](http://travis-ci.org/fredemmott/rxhp)

What is this?!
==============

RXhp is a system for producing HTML or XHTML from Ruby.

```ruby
require 'rxhp'

class MyPage < Rxhp::ComposableElement
  # If you don't want to prefix every tag with 'H.', you can just
  # import Rxhp::Html - but then you've replaced builtins such as Kernel.p
  # so it's not a nice thing to do :)
  H = Rxhp::Html
  def compose
    H.html do
      H.body do
        H.p '<Hello, World>'
      end
    end
  end
end

puts MyPage.new.render
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

Why should I use it?
====================

It's designed to make development and debugging faster - several features
help with this:

Attribute validation
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
<!-- this is evaluated as checked = true - can't do this with Rxhp -->
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

Validates singleton elements
----------------------------

You'll get exceptions for things like this:

```ruby
input(:type => :checkbox, :name => :foo) do
  'My checkbox label'
end
```

You probably meant:

```ruby
input(:type => :checkbox, :name => :foo)
label(:for => :foo) do
  'My checkbox label'
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
      br
      p 'bar'
    end
  end
end
```

Just by changing the render flags, you can get XHTML...

```html
<!DOCTYPE HTML PUBLIC
  "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <body>
    <div>
      <p>foo</p>
      <br />
      <p>bar</p>
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
      <p>foo</p>
      <br>
      <p>bar</p>
    </div>
  </body>
</html>
```

... or still, technically, HTML:

```html
<html><body><div><p>foo<br><p>bar</div>
```

How fast is it?
===============

Fast enough to be irrelevant in nearly any situation - see:

* [A trivial benchmark script](https://gist.github.com/1653689)
* [Output on a 2.67Ghz i7 against Ruby 1.8.7](https://gist.github.com/1653697)

That's < 0.5ms per render in that example. Some other template systems are
significantly faster, but this is still highly unlikely to be worrying in
any modern webapp.

What stage is this at?
======================

Not yet used in production.

There's a fair few tests, but documentation needs a lot of work.

How do the classes fit together?
================================

![class diagram](https://github.com/fredemmott/rxhp/raw/master/docs/base-classes.png)

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
