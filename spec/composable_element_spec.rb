require 'spec_helper'

class SubKlass < ::Rxhp::ComposableElement
  def compose
    Rxhp::Html.p do
      yield
    end
  end
end

module My
  class OtherSubKlass < ::Rxhp::ComposableElement
    def compose
      results = yield
      Rxhp::Html.p do
        Rxhp::Html.fragment results
      end
    end
  end
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
    end.should raise_error(Rxhp::ValidationError)
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
    end.should raise_error(Rxhp::ValidationError)
  end

  it 'should allow attributes to be required' do
    lambda do
      SubKlass.require_attributes(:foo => Object)
    end.should_not raise_error

    lambda do
      SubKlass.new
    end.should raise_error(Rxhp::ValidationError)

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

  it 'raises NotImplementedError for #compose' do
    lambda do
      Rxhp::ComposableElement.new.compose
    end.should raise_error(NotImplementedError)
  end

  context 'when subclassed' do
    it 'creates a factory function in the correct module' do
      lambda{ sub_klass }.should_not raise_error(NoMethodError)
      lambda{ My::other_sub_klass }.should_not raise_error(NoMethodError)

      sub_klass.should be_a SubKlass
      My::other_sub_klass.should be_a My::OtherSubKlass
    end
  end

  context 'with child elements' do
    it 'embeds them at yield when rendering' do
      tree = sub_klass do
        Rxhp::Html.text 'bar'
      end
      tree.render.should include 'bar'
    end

    it 'does not embed them multiple times when rendering' do
      tree = sub_klass do
        Rxhp::Html.text 'bar'
      end
      tree.render.should_not match /bar.*bar/m
    end

    it 'can embed them at a later point if not in a Rxhp scope' do
      tree = My.other_sub_klass do
        Rxhp::Html.text 'bar'
      end
      tree.children.count.should == 1
      result = tree.render
      result.should match %r(<p>.*bar.*</p>)m
    end

    it "does not embed them multiple times if stored then included" do
      tree = My.other_sub_klass do
        Rxhp::Html.text 'bar'
      end
      tree.render.should_not match /bar.*bar/m
    end
  end
end
