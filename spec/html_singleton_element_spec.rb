require 'spec_helper'

describe Rxhp::HtmlSingletonElement do
  describe Rxhp::HtmlSingletonElement::HasChildrenError do
    before :all do
      @klass = Rxhp::HtmlSingletonElement::HasChildrenError
    end

    it 'is a Rxhp::ValidationError' do
      @klass.ancestors.include? Rxhp::ValidationError
    end
  end

  describe '#render' do
    before :each do
      @it = Rxhp::HtmlSingletonElement.new
      def @it.tag_name; 'foo'; end
    end

    it 'raises an error if there are children' do
      @it.children.push 'bar'
      lambda { @it.render }.should raise_error(Rxhp::HtmlSingletonElement::HasChildrenError)
    end

    context 'in HTML mode' do
      it 'should create an opening tag' do
        @it.render(
          :format => Rxhp::HTML_FORMAT
        ).should include '<foo>'
      end

      it 'should not include a closing tag' do
        @it.render(
          :format => Rxhp::HTML_FORMAT
        ).should_not include '</foo>'
      end
    end

    context 'in XHTML mode' do
      it 'should create a self-closing tag' do
        @it.render(
          :format => Rxhp::XHTML_FORMAT
        ).should include '<foo />'
      end

      it 'should not create an opening tag' do
        @it.render(
          :format => Rxhp::XHTML_FORMAT
        ).should_not include '<foo>'
      end

      it 'should not include a closing tag' do
        @it.render(
          :format => Rxhp::XHTML_FORMAT
        ).should_not include '</foo>'
      end
    end
  end
end
