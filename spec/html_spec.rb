require 'spec_helper'

describe Rxhp::Html do
  context 'attribute validators' do
    it 'should allow tags to accept additional attributes' do
      e = Rxhp::Html::Base.new
      e.attributes[:href] = 'foo'
      e.valid_attributes?.should be_true
    end

    it 'should propogate attribute definitions to subclasses' do
      e = Rxhp::Html::Base.new
      e.attributes[:style] = 'foo'
      e.valid_attributes?.should be_true
    end

    it 'should not propogate attribute definitions to the superclass' do
      e = Rxhp::HtmlElement.new
      e.attributes[:href] = 'foo'
      e.valid_attributes?.should be_false
    end

    it 'should not propogate attribuet definitions to other elements' do
      e = Rxhp::Html::Title.new
      e.attributes[:href] = 'foo'
      e.valid_attributes?.should be_false
    end
  end

  it 'should raise an exception for invalid attributes at creation time' do
    lambda do
      Rxhp::Html::Base.new(:herp => 'derp')
    end.should raise_error(Rxhp::AttributeValidator::ValidationError)
  end

  it 'should raise an exception for invalid attributes at render time' do
    e = Rxhp::Html::Html.new
    e.attributes[:herp] = 'derp'
    lambda do
      e.render
    end.should raise_error(Rxhp::AttributeValidator::ValidationError)
  end

  it 'should not raise an exception for perfectly cromulent attributes' do
    lambda do
      Rxhp::Html::Html.new('data-herp' => 'derp')
    end.should_not raise_error
  end

  describe Rxhp::Html::Link do
    it 'should allow rel="nofollow"' do
      e = Rxhp::Html::Link.new
      e.attributes[:rel] = 'nofollow'
      e.valid_attributes?.should be_true
    end

    it 'should not allow rel="bogus"' do
      e = Rxhp::Html::Link.new
      e.attributes[:rel] = 'bogus'
      e.valid_attributes?.should be_false
    end

    it 'should allow multiple space-separated values' do
      e = Rxhp::Html::Link.new
      e.attributes[:rel] = 'nofollow noreferrer'
      e.valid_attributes?.should be_true
    end
  end
end
