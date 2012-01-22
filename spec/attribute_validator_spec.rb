require 'rxhp/attribute_validator'
require 'rxhp/element'

def match? *args
  Rxhp::AttributeValidator.match? *args
end

describe Rxhp::AttributeValidator do
  describe '.match?' do
    context 'with a string matcher' do
      it 'should allow an exact match against the name' do
        match?('foo', 'foo', 'bar').should be_true
      end

      it 'should not allow a prefix match against the name' do
        match?('foo', 'foobar', 'baz').should be_false
      end

      it 'should not allow a suffix match against the name' do
        match?('foo', 'barfoo', 'baz').should be_false
      end
    end

    context 'with a symbol matcher' do
      it 'should allow an exact match against the name' do
        match?(:foo, 'foo', 'bar').should be_true
      end

      it 'should treat underscores as hyphens' do
        match?(:foo_bar, 'foo-bar', 'baz').should be_true
      end

      it 'should not allow a prefix match against the name' do
        match?(:foo, 'foobar', 'baz').should be_false
      end

      it 'should not allow a suffix match against the name' do
        match?(:foo, 'barfoo', 'baz').should be_false
      end
    end

    context 'with a regexp matcher' do
      it 'should allow an exact match against the name' do
        match?(/foo/, 'foo', 'bar').should be_true
      end

      it 'should allow a substring match against the name' do
        match?(/foo/, 'afoob', 'bar').should be_true
      end

      it 'should not match something arbitrary' do
        match?(/foo/, 'bar', 'baz').should be_false
      end

      it 'should allow anchored matches' do
        match?(/^foo/, 'foobar', 'baz').should be_true
        match?(/^foo/, 'barfoo', 'baz').should be_false
        match?(/foo$/, 'barfoo', 'baz').should be_true
        match?(/foo$/, 'foobar', 'baz').should be_false
      end
    end

    context 'with an Array matcher' do
      it 'should default to not accepting' do
        match?([], 'foo', 'bar').should be_false
      end

      it 'should accept any matcher in the array' do
        match?(['foo'], 'foo', 'bar').should be_true
        match?([/^foo/], 'foo', 'bar').should be_true
        match?(['bar'], 'foo', 'bar').should be_false
        match?(['bar', 'foo'], 'foo', 'bar').should be_true
      end
    end

    context 'with a Hash matcher' do
      it 'should treat Object as a wildcard' do
        match?({Object => Object}, 'foo', 'bar').should be_true
      end

      it 'should accept a name match with any value' do
        match?({'foo' => Object}, 'foo', 'bar').should be_true
        match?({/foo/ => Object}, 'foo', 'bar').should be_true
      end

      it 'should reject names that do not match' do
        match?({'foo' => Object}, 'baz', 'bar').should be_false
        match?({/foo/ => Object}, 'baz', 'bar').should be_false
      end

      it 'should apply matchers to values' do
        match?({'foo' => 'bar'}, 'foo', 'bar').should be_true
        match?({'foo' => 'bar'}, 'foo', 'baz').should be_false
      end

      it 'should accept symbols for name matchers' do
        match?({:foo => 'bar'}, 'foo', 'bar').should be_true
        match?({:baz => 'bar'}, 'foo', 'bar').should be_false
      end

      it 'should take arrays for values as enums' do
        matcher = { :foo => ['bar', 'baz'] }
        match?(matcher, 'foo', 'bar').should be_true
        match?(matcher, 'foo', 'baz').should be_true
        match?(matcher, 'foo', 'nyan').should be_false
      end

      it 'should take arrays for names as enums' do
        matcher = { ['foo', 'bar'] => 'baz' }
        match?(matcher, 'foo', 'baz').should be_true
        match?(matcher, 'bar', 'baz').should be_true
        match?(matcher, 'foo', 'bar').should be_false
      end
    end
  end

  context 'when included' do
    before :each do
      @klass = Rxhp::Element
      @klass.instance_eval do
        include Rxhp::AttributeValidator
      end
      @instance = @klass.new
    end

    it 'should define #valid_attributes?' do
      @instance.should respond_to :valid_attributes?
    end

    it 'should define #validate_attributes!' do
      @instance.should respond_to :validate_attributes!
    end

    it 'should define .acceptable_attributes' do
      @klass.should respond_to :acceptable_attributes
    end

    it 'should define .required_attributes' do
      @klass.should respond_to :required_attributes
    end

    it 'should define .accept_attributes' do
      @klass.should respond_to :accept_attributes
    end

    it 'should define .require_attributes' do
      @klass.should respond_to :require_attributes
    end

    context 'when subclassed' do
      before :each do
        @klass.accept_attributes :foo
        @subklass = Class.new(@klass)
      end

      it 'should inherit default attributes' do
        @subklass.acceptable_attributes.should == @klass.acceptable_attributes
      end

      it 'should not change add subclass attributes to parent' do
        @subklass.accept_attributes :bar
        @klass.acceptable_attributes.should_not include :bar
      end
    end

    describe Rxhp::AttributeValidator do
      it 'should be a descendent of Rxhp::ScriptError' do
        ancestors = Rxhp::AttributeValidator::ValidationError.ancestors
        ancestors.should include Rxhp::ScriptError
        ancestors.should include ::ScriptError
      end
    end

    describe '#validate_attributes!' do
      it 'should raise a ValidationError with invalid attributes' do
        @instance.attributes['foo'] = 'bar'
        lambda do
          @instance.validate_attributes!
        end.should raise_error(Rxhp::AttributeValidator::ValidationError)
      end
    end

    describe '#valid_attributes?' do
      before :each do
        @instance.attributes['foo'] = 'bar'
      end

      it 'should return false if a required attribute is missing' do
        @klass.require_attributes 'bar'
        @instance.valid_attributes?.should be_false
      end

      it 'should return false if both required and invalid attributes are present' do
        @klass.require_attributes 'foo'
        @instance.attributes = {'foo' => 'bar', 'herp' => 'derp'}
        @instance.valid_attributes?.should be_false
      end

      it 'should return true if all required attributes are provided' do
        @klass.require_attributes ['foo', 'herp']
        @instance.attributes = {'foo' => 'bar', 'herp' => 'derp'}
        @instance.valid_attributes?.should be_true
      end

      it 'should return false if any required attribute is missing' do
        @klass.require_attributes 'herp'
        @instance.attributes = {'foo' => 'bar'}
        @instance.valid_attributes?.should be_false
      end

      it 'should accept a symbol name' do
        @instance.attributes = {:foo => 'bar'}
        @klass.accept_attributes('foo' => 'bar')
        @instance.valid_attributes?.should be_true
      end

      it 'should accept an exact name-value matcher' do
        @klass.accept_attributes('foo' => 'bar')
        @instance.valid_attributes?.should be_true
      end

      it 'should accept a name-only matcher' do
        @klass.accept_attributes('foo' => Object)
        @instance.valid_attributes?.should be_true
      end

      it 'should not accept a name mismatch' do
        @klass.accept_attributes('baz' => Object)
        @instance.valid_attributes?.should be_false
      end

      it 'should not accept a value mismatch' do
        @klass.accept_attributes('foo' => 'baz')
        @instance.valid_attributes?.should be_false
      end
    end
  end
end
