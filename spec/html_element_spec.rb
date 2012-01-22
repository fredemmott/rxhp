require 'rxhp/error'
require 'rxhp/html_element'

describe Rxhp::HtmlElement do
  before :each do
    @it = Rxhp::HtmlElement.new
    def @it.tag_name; 'foo'; end
  end

  describe '#validate_attributes!' do
    before :each do
      @call = lambda { @it.validate_attributes! }
    end

    it 'should accept a word id' do
      @it.attributes['id'] = 'foo'
      @call.should_not raise_error
    end

    it 'should not accept an id with a space in it' do
      @it.attributes['id'] = 'foo bar'
      @call.should raise_error
    end

    it 'should not accept a completely bogus attribute' do
      @it.attributes['foo'] = 'bar'
      @call.should raise_error
    end

    it 'should accept an arbitrary data- attribute' do
      @it.attributes['data-foo'] = 'bar'
      @call.should_not raise_error
    end

    it 'should not accept "data-"' do
      @it.attributes['data-'] = 'foo'
      @call.should raise_error
    end

    it 'should accept onclick' do
      # Make sure Rxhp::Html:::GLOBAL_EVENT_HANDLERS got pulled in
      @it.attributes['onclick'] = 'foo'
      @call.should_not raise_error
    end

    context 'with boolean attributes' do
      it 'should accept (true)' do
        @it.attributes[:hidden] = true
        @call.should_not raise_error
      end

      it 'should not accept "true"' do
        @it.attributes[:hidden] = 'true'
        @call.should raise_error
      end
    end

    context 'with Integer attributes' do
      it 'should accept accept a fixnum' do
        @it.attributes[:tabindex] = 3
        @call.should_not raise_error
      end

      it 'should not accept a string' do
        @it.attributes[:tabindex] = '3'
        @call.should raise_error
      end
    end

    context 'with String attributes' do
      it 'should accept an arbitrary string' do
        @it.attributes[:title] = 'foo bar baz'
        @call.should_not raise_error
      end

      it 'should not accept a number' do
        @it.attributes[:title] = 3
        @call.should raise_error
      end
    end

    context 'with enum(true|false) attributes' do
      it 'should accept "true"' do
        @it.attributes[:spellcheck] = 'true'
        @call.should_not raise_error
      end

      it 'should not accept (true)' do
        @it.attributes[:spellcheck] = true
        @call.should raise_error
      end

      it 'should not accept an arbitrary string' do
        @it.attributes[:spellcheck] = 'foo'
        @it.should raise_error
      end
    end
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

    context 'with boolean attributes' do
      it 'should skip the attribute if false' do
        @it.attributes[:hidden] = false

        @it.render(
          :format => Rxhp::HTML_FORMAT
        ).should_not include 'hidden'

        @it.render(
          :format => Rxhp::XHTML_FORMAT
        ).should_not include 'hidden'
      end

      it 'should include the attribute without a value if true in HTML' do
        @it.attributes['hidden'] = true

        result = @it.render(
          :format => Rxhp::HTML_FORMAT
        )

        result.should include ' hidden'
        result.should_not include ' hidden='
      end

      it 'should include name=name if true in XHTML' do
        @it.attributes['hidden'] = true

        result = @it.render(
          :format => Rxhp::XHTML_FORMAT
        )

        result.should match /\shidden=(["'])hidden\1/
      end
    end

    it 'should include attributes' do
      @it.attributes['data-bar'] = 'baz'
      @it.render.should include '<foo data-bar="baz">'
    end

    it 'should escape HTML in contents' do
      @it.children.push '<bar>'
      result = @it.render
      result.should_not include '<bar'
      result.should_not include 'bar>'
      result.should include '&lt;bar&gt;'
    end

    it 'should escape HTML in attributes' do
      @it.attributes['data-bar'] = '<baz>'
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
      @it.attributes['data-single'] = "a'b"
      @it.attributes['data-double'] = 'a"b'

      result = @it.render
      result.should_not match %r(=(['"])[^ ]*\1[^ ]*\1)
    end
  end
end
