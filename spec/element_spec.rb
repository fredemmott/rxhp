require 'spec_helper'

describe Rxhp::Element do
  describe '#initialize' do
    it 'should default to having no children' do
      e = Rxhp::Element.new
      e.children.should be_empty
      e.children?.should be_false
    end

    it 'should default to having no attributes' do
      e = Rxhp::Element.new
      e.attributes.should be_empty
    end
  end

  describe '#validate!' do
    it 'should not raise an error' do
      e = Rxhp::Element.new
      lambda{ e.validate! }.should_not raise_error
    end
  end

  describe 'valid?' do
    it 'should return true by default' do
      Rxhp::Element.new.valid?.should be_true
    end

    it 'should return false if validate! raises a ValidationError' do
      e = Rxhp::Element.new
      e.should_receive(:validate!).and_raise(Rxhp::ValidationError.new)

      e.valid?.should be_false
    end

    it 'should not block any other ScriptError' do
      e = Rxhp::Element.new
      e.should_receive(:validate!).and_raise(Rxhp::ScriptError.new)
      lambda{e.valid?}.should raise_error(Rxhp::ScriptError)
    end

    it 'should not block normal errors' do
      e = Rxhp::Element.new
      e.should_receive(:validate!).and_raise('herpity derpity')
      lambda{e.valid?}.should raise_error('herpity derpity')
    end
  end

  describe '#render' do
    it 'should not have a default implementation' do
      e = Rxhp::Element.new
      lambda{e.render}.should raise_error(NotImplementedError)
    end
  end

  describe '#render_string' do
    it 'should not have a default implementation' do
      e = Rxhp::Element.new
      lambda{e.render_string :a, :b}.should raise_error(NotImplementedError)
    end
  end

  describe '#render_children' do
    it 'should return nil if there are no children' do
      Rxhp::Element.new.render_children(nil).should be_nil
    end

    it 'should include #render from children' do
      root = Rxhp::Element.new
      child = Rxhp::Element.new

      child.should_receive(
        :render
      ).with(
        instance_of(Hash)
      ).and_return(
        'NyanNyanNyan'
      )

      root.children.push child
      root.render_children.should == 'NyanNyanNyan'
    end

    it 'should pass options to children' do
      options = {
        __FILE__ => __LINE__,
      }
      root = Rxhp::Element.new
      child = Rxhp::Element.new

      child.should_receive(
        :render
      ).with(
        options
      ).and_return(
        String.new
      )

      root.children.push child
      root.render_children options
    end

    it 'should treat array children as several children' do
      options = {
        __FILE__ => __LINE__
      }
      root = Rxhp::Element.new
      herp = Rxhp::Element.new
      derp = Rxhp::Element.new
      root.children.push [herp, derp]

      herp.should_receive(:render).with(options).and_return(String.new)
      derp.should_receive(:render).with(options).and_return(String.new)

      root.render_children options
    end
  end

  describe '#fill_options' do
    it 'should preserve given options' do
      e = Rxhp::Element.new

      # Just check there is a default indent
      default = e.fill_options({})[:indent]
      default.should be_a(Fixnum)

      # Do what we came here to do :)
      my_indent = default + 10
      indent = e.fill_options(:indent => my_indent)[:indent]
      indent.should == indent
    end
  end
end
