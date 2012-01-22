require 'spec_helper'

describe Rxhp::Html::Html do
  it 'renders an HTML 5 doctype by default' do
    Rxhp::Html::Html.new.render.should include Rxhp::HTML_5
  end

  it 'skips the doctype if told to' do
    Rxhp::Html::Html.new.render(
      :skip_doctype => true
    ).should_not include Rxhp::HTML_5
  end
end
