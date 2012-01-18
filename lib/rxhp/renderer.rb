module Rxhp
  autoload :Fragment, 'rxhp/fragment'

  # Mixin for anything that needs to be able to keep track of the render
  # stack.
  #
  # This is a separate stack to usual, as:
  #
  # html do
  #   # Same 'self' here as...
  #   body do
  #     # ... here
  #   end
  # end
  #
  # ... but in that example, 'body' needs to be a child of 'html', and
  # 'html' doesn't have a parent. We need /somewhere/ to store it, so
  # we create an Rxhp::Fragment if the render stack is empty.
  #
  # HtmlElement explicity changes that to 'self'.
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
