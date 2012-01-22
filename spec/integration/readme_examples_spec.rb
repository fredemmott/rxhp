require 'spec_helper'

# Yes, these are brittle, but worth it for the confidence that the whole
# stack works together correctly.

describe 'The README.md examples' do
  context 'in "What is this?"' do
    before :each do
      h = Rxhp::Html
      @doc = h.html do
        h.body do
          h.p '<Hello, World>'
        end
      end
    end

    it 'should render HTML correctly' do
      @doc.render(
        :skip_doctype => true,
        :pretty => false
      ).should == '<html><body><p>&lt;Hello, World&gt;</p></body></html>'
    end

    it 'should render tiny HTML correctly' do
      @doc.render(
        :skip_doctype => true,
        :pretty => false,
        :format => Rxhp::TINY_HTML_FORMAT
      ).should == '<html><body><p>&lt;Hello, World&gt;'
    end
  end

  context 'in "Attribute validation"' do
    it 'should allow data-herp' do
      lambda do
        Rxhp::Html.html('data-herp' => 'derp')
      end.should_not raise_error
    end

    it 'should not allow dtaa-herp [sic]' do
      lambda do
        Rxhp::Html.html('dtaa-herp' => 'derp')
      end.should raise_error(Rxhp::AttributeValidator::UnacceptableAttributeError)
    end
  end

  context 'in "Singleton Validation"' do
    it 'does not allow children of <input>' do
      h = Rxhp::Html
      lambda do
        h.input(:type => :checkbox, :name => :foo) do
          h.text 'My checkbox label'
        end
      end.should raise_error(Rxhp::HtmlSingletonElement::HasChildrenError)
    end

    it 'allows inputs with associated labels' do
      h = Rxhp::Html
      lambda do
        h.div do
          h.input(:type => :checkbox, :name => :foo)
          h.label(:for => :foo) do
            h.text 'My Checkbox label'
          end
        end.render
      end.should_not raise_error
    end
  end

  context 'in "Produces HTML or XHTML"' do
    before :all do
      h = Rxhp::Html
      @tree = h.html do
        h.body do
          h.div do
            h.p 'foo'
            h.input(:type => :checkbox, :checked => true)
          end
        end
      end
    end

    it 'produces XHTML as quoted' do
      @tree.render(
        :doctype => Rxhp::XHTML_1_0_STRICT,
        :format => Rxhp::XHTML_FORMAT
      ).should match(
%r{<!DOCTYPE html PUBLIC
  "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <body>
    <div>
      <p>
        foo
      </p>
      <input( type="checkbox"| checked="checked"){2} />
    </div>
  </body>
</html>}m)
    end

    it 'produces HTML as quoted' do
      @tree.render().should match(
%r{<!DOCTYPE html>
<html>
  <body>
    <div>
      <p>
        foo
      </p>
      <input( (type="checkbox"|checked)){2}>
    </div>
  </body>
</html>}m)
    end

    it 'produces tiny HTML as quoted' do
      @tree.render(
        :pretty => false,
        :format => Rxhp::TINY_HTML_FORMAT,
        :skip_doctype => true
      ).should match(
%r{<html><body><div><p>foo<input( type="checkbox"| checked){2}></div>}m
      )
    end
  end

  context 'in "Strings in blocks"' do
    it 'should raise an exception for a single string child' do
      lambda do
        Rxhp::Html.p do
          'foo'
        end
      end.should raise_error(Rxhp::ScriptError)
    end

    it 'should raise an exception for multiple string children' do
      lambda do
        Rxhp::Html.p do
          'foo'
          'bar'
        end
      end.should raise_error(Rxhp::ScriptError)
    end

    it 'should render a string child specified as a parameter' do
      Rxhp::Html.p('foo').render.should match %r(<p>.*foo.*</p>)m
    end

    context 'with multiple string children attached with text' do
      before :each do
        @tree = Rxhp::Html.p do
          Rxhp::Html.text 'foo'
          Rxhp::Html.text 'bar'
        end
      end

      it 'should include them' do
        @tree.render.should match %r(<p>.*foo.*bar.*</p>)m
      end

      it 'should not add whitespace' do
        @tree.render.should include 'foobar'
      end
    end
  end
end
