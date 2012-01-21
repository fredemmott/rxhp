require File.dirname(__FILE__) + '/_helper.rb'
require 'rxhp/html_self_closing_element'

describe Rxhp::HtmlSelfClosingElement do
  describe '#render' do
    before :each do
      @it = Rxhp::HtmlSelfClosingElement.new
      def @it.tag_name; 'foo'; end
    end

    context 'in HTML' do
      context 'with no children' do
        before :each do
          @out = @it.render(:format => Rxhp::HTML_FORMAT)
        end

        it 'should create an opening tag' do
          @out.should include '<foo>'
        end

        it 'should create a closing tag' do
          @out.should include '</foo>'
        end
      end
    end

    context 'in tiny HTML' do
      context 'with no children' do
        before :each do
          @out = @it.render(:format => Rxhp::TINY_HTML_FORMAT)
        end

        it 'should create an opening tag' do
          @out.should include '<foo>'
        end

        it 'should not create a closing tag' do
          @out.should_not include '</foo>'
        end
      end

      context 'with children' do
        before :each do
          @it.children.push 'bar'
          @out = @it.render(:format => Rxhp::TINY_HTML_FORMAT)
        end

        it 'should create an opening tag' do
          @out.should include '<foo>'
        end

        it 'should not create a closing tag' do
          @out.should_not include '</foo>'
        end

        it 'should incldue the children' do
          @out.should include 'bar'
        end
      end
    end
  end
end
