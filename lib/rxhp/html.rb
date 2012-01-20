require 'rxhp/data/html/attributes'
require 'rxhp/data/html/tags'

Rxhp::Html::TAGS.each do |tag, data|
  if data[:require]
    require data[:require]
  else
    data = {
      :is_a => Rxhp::HtmlElement,
      :attributes => [
        Rxhp::Html::GLOBAL_ATTRIBUTES,
        Rxhp::Html::GLOBAL_EVENT_HANDLERS,
      ],
    }.merge(data)

    klass_name = tag.to_s.dup
    klass_name[0] = klass_name[0,1].upcase
    klass = Class.new(data[:is_a])
    klass.send(:define_method, :tag_name) { tag.to_s }

    Rxhp::Html.const_set(klass_name, klass)

    Rxhp::Scope.define_element tag, klass, Rxhp::Html
  end
end
