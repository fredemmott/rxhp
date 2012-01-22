require 'spec_helper'

describe Rxhp::Scope do
  describe '.current' do
    it 'should return a fragment if no container' do
      Rxhp::Scope.current.should be_a(Rxhp::Fragment)
    end
  end

  describe '.with_parent' do
    it 'should change the scope' do
      parent = :test_parent
      Rxhp::Scope.with_parent(parent) do
        Rxhp::Scope.current.should == parent
      end
    end
  end

  describe '.define_element' do
    before(:each) do
      @ns = Module.new
      @name = :foo
      @klass = Class.new(Rxhp::Element)
      Rxhp::Scope.define_element(@name, @klass, @ns)
    end

    it 'creates NameSpace.foo()' do
      @ns.public_methods.map(&:to_sym).should include(@name)
    end

    it 'creates NameSpace#foo()' do
      @ns.public_instance_methods.map(&:to_sym).should include(@name)
    end

    context 'defines a method, that when called' do
      it 'creates an instance of the element' do
        @ns.send(@name).should be_a(@klass)
      end

      it 'creates an element with no children' do
        it = @ns.send(@name)
        it.should be_a(Rxhp::Element)
        it.children.should be_empty
      end

      it 'creates an element with no attributes' do
        it = @ns.send(@name)
        it.attributes.should be_empty
      end

      it 'raises an error if the result of a block is a string' do
        lambda do
          it = @ns.send(@name) do
            'foo'
          end.should raise_error(Rxhp::ScriptError)
        end
      end
      
      it 'includes elements created in a block as children' do
        it = @ns.send(@name) do
          @ns.send(@name)
        end

        it.should be_a(@klass)
        it.children.count.should == 1

        child = it.children.first
        child.should be_a @klass
        child.children.should_not be(it)
        child.children.should be_empty
      end

      it 'includes elements passed as parameters as children do' do
        child = @ns.send(@name)
        it = @ns.send(@name, child)

        it.children.count.should == 1
        it.children.first.should be(child)
      end

      it 'converts named parameters to attributes' do
        it = @ns.send(@name, :foo => 'bar')

        it.attributes.count.should == 1
        it.attributes[:foo].should == 'bar'
      end

      it 'works with attribute and child parameters at the same time' do
        child = @ns.send(@name)
        it = @ns.send(@name, child, :foo => 'bar')

        it.children.should == [child]
        it.attributes.should == {:foo => 'bar'}
      end
    end
  end
end
