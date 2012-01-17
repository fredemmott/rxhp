module Rxhp
  autoload :Fragment, 'rxhp/fragment'
  module Renderer
    def render_context
      render_stack.last || Rxhp::Fragment.new
    end

    def render_stack
      @render_stack ||= []
    end

    def sub_render context
      render_stack.push context
      result = yield
      render_stack.pop
      result
    end
  end
end
