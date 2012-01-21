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
