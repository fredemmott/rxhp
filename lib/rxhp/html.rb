require 'rxhp/data/html/attributes'
require 'rxhp/data/html/tags'

module Rxhp
  module Html
    def fragment x
      Rxhp::Scope.current.children.push x
    end
    alias :frag :fragment
    alias :text :fragment

    class <<self
      def fragment x
        Rxhp::Scope.current.children.push x
      end
      alias :frag :fragment
      alias :text :fragment
    end
  end
end

Rxhp::Html::TAGS.each do |tag, data|
  if data[:require]
    require data[:require]
  else
    data = {
      :is_a => Rxhp::HtmlElement,
    }.merge(data)

    klass_name = tag.to_s.dup
    klass_name[0] = klass_name[0,1].upcase
    klass = Class.new(data[:is_a])
    klass.send(:define_method, :tag_name) { tag.to_s }

    if data[:attributes]
      klass.accept_attributes data[:attributes]
    end

    Rxhp::Html.const_set(klass_name, klass)

    Rxhp::Scope.define_element tag, klass, Rxhp::Html
  end
end
