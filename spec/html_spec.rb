require File.dirname(__FILE__) + '/_helper.rb'

require 'rxhp/html'

describe Rxhp::Html do
  context 'attribute validators' do
    it 'should allow tags to accept additional attributes' do
      e = Rxhp::Html::Base.new(:href => 'foo')
      e.valid_attributes?.should be_true
    end

    it 'should propogate attribetu definitions to subclasses' do
      e = Rxhp::Html::Base.new(:style => 'foo')
      e.valid_attributes?.should be_true
    end

    it 'should not propogate attribute definitions to the superclass' do
      e = Rxhp::HtmlElement.new(:href => 'foo')
      e.valid_attributes?.should be_false
    end

    it 'should not propogate attribuet definitions to other elements' do
      e = Rxhp::Html::Title.new(:href => 'foo')
      e.valid_attributes?.should be_false
    end
  end
end
