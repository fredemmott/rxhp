require 'rxhp/fragment'

describe Rxhp::Fragment do
  describe '#render' do
    it 'should call render_children' do
      it = Rxhp::Fragment.new

      it.should_receive(
        :render_children
      ).and_return('_OH_HAI_NYAN_')

      it.render.should == '_OH_HAI_NYAN_'
    end

    it 'should pass options to render_children' do
      it = Rxhp::Fragment.new
      options = {:foo => :bar}

      it.should_receive(
        :render_children
      ).with(
        options
      )

      it.render(options)
    end

    it 'should include child nodes in it\'s rendering' do
      frag = Rxhp::Fragment.new
      herp = Rxhp::Element.new
      def herp.render *args
        'derp'
      end

      frag.children.push herp
      frag.render.should include 'derp'
    end
  end
end
