require File.dirname(__FILE__) + '/_helper.rb'
require 'rxhp/html_element'

describe Rxhp::HtmlElement do
  before(:each) do
    @it = Rxhp::HtmlElement.new
    def @it.tag_name; 'foo'; end
  end

  describe '#render' do
    context 'without pretty rendering' do
      it 'should create open and close tags for an empty HTML element' do
        @it.render(
          :pretty => false,
          :format => Rxhp::HTML_FORMAT
        ).should == '<foo></foo>'
      end

      it 'should create a self-closing tag for an empty XHTML element' do
        @it.render(
          :pretty => false,
          :format => Rxhp::XHTML_FORMAT
        ).should == '<foo />'
      end

      it 'should include child nodes' do
        @it.children.push 'bar'
        @it.render(
          :pretty => false
        ).should == '<foo>bar</foo>'
      end

      it 'should include grandchild nodes' do
        child = Rxhp::HtmlElement.new
        def child.tag_name; 'bar'; end
        child.children.push 'baz'
        @it.children.push child

        @it.render(
          :pretty => false
        ).should == '<foo><bar>baz</bar></foo>'
      end
    end

    context 'with pretty rendering' do
      it 'should create open and close tags for an empty HTML element' do
        @it.render(
          :pretty => true,
          :format => Rxhp::HTML_FORMAT
        ).should match %r(^<foo>\s*</foo>\s*$)
      end

      it 'should create a self-closing tag for an empty XHTML element' do
        @it.render(
          :pretty => true,
          :format => Rxhp::XHTML_FORMAT
        ).should match %r(^<foo />$)
      end

      it 'should indent child nodes' do
        @it.children.push 'bar'
        @it.render(
          :pretty => true
        ).should match %r(^<foo>\n\s+bar\n</foo>$)
      end

      it 'should indent grandchild nodes' do
        child = Rxhp::HtmlElement.new
        def child.tag_name; 'bar'; end
        child.children.push 'baz'
        @it.children.push child

        @it.render(
          :pretty => true
        ).should match %r(^<foo>\n(\s+)<bar>\n\1\1baz\n\1</bar>\n</foo>$)
      end
    end

    it 'should include attributes' do
      @it.attributes['bar'] = 'baz'
      @it.render.should include '<foo bar="baz">'
    end

    it 'should escape HTML in contents' do
      @it.children.push '<bar>'
      result = @it.render
      result.should_not include '<bar'
      result.should_not include 'bar>'
      result.should include '&lt;bar&gt;'
    end

    it 'should escape HTML in attributes' do
      @it.attributes['bar'] = '<baz>'
      result = @it.render
      result.should_not include '<baz'
      result.should_not include 'baz>'
      result.should include '&lt;baz&gt;'
    end

    it 'should escape ampersands' do
      @it.children.push '&bar'
      result = @it.render
      result.should_not include '&bar'
      result.should include '&amp;bar'
    end

    it 'should escape quotes in attribute values' do
      @it.attributes['single'] = "a'b"
      @it.attributes['double'] = 'a"b'

      result = @it.render
      result.should_not match %r(=(['"])[^ ]*\1[^ ]*\1)
    end
  end
end
