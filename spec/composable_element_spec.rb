require 'spec_helper'

class SubKlass < ::Rxhp::ComposableElement
end

describe Rxhp::ComposableElement do
  before :each do
    SubKlass.acceptable_attributes = []
    SubKlass.required_attributes = []
  end

  it 'should be able to be constructed' do
    lambda do
      Rxhp::ComposableElement.new
    end.should_not raise_error
  end

  it 'should raise a validation error if any attributes are given' do
    lambda do
      Rxhp::ComposableElement.new(:foo => :bar)
    end.should raise_error(Rxhp::AttributeValidator::ValidationError)
  end

  it 'should allow attributes to be whitelisted' do
    lambda do
      SubKlass.accept_attributes(:foo => Object)
    end.should_not raise_error
    lambda do
      SubKlass.new(:foo => :bar)
    end.should_not raise_error
    lambda do
      SubKlass.new(:bar => :baz)
    end.should raise_error(Rxhp::AttributeValidator::ValidationError)
  end

  it 'should allow attributes to be required' do
    lambda do
      SubKlass.require_attributes(:foo => Object)
    end.should_not raise_error

    lambda do
      SubKlass.new
    end.should raise_error(Rxhp::AttributeValidator::ValidationError)

    lambda do
      SubKlass.new(:foo => :bar)
    end.should_not raise_error
  end

  it 'should include the results of compose in the rendering' do
    e = SubKlass.new
    child = Rxhp::HtmlElement.new
    def child.tag_name; 'herpity'; end
    e.should_receive(:compose).and_return(child)
    e.render.should include 'herpity'
  end
end
