#!/usr/bin/env ruby
require 'benchmark'
require 'rxhp'

H = Rxhp::Html

def make_document
  H.html {
    H.head
    H.body(class: 'newsfeed', id: 'gibberish') {
      100.times {
        H.div(
          class: 'story',
          id: 'gibberish',
          style: 'gibberish',
          onclick: 'gibberish',
          onmouseover: 'gibberish',
        ) {
          H.img(src: 'example.jpg', title: 'gibberish')
          H.p 'gibberish'
          10.times {
            H.div(
              class: 'comment',
              id: 'gibberish',
              style: 'gibberish',
              onclick: 'gibberish',
              onmouseover: 'gibberish',
            ) {
              H.img(src: 'profile.jpg', title: 'gibberish')
              H.p 'gibberish'
            }
          }
          H.form(action: 'example.php', method: 'post') {
            H.textarea(name: 'gibberish', rows: 3, placeholder: 'gibberish')
            H.input(type: 'submit', name: 'gibberish', value: 'gibberish')
          }
        }
        H.hr
      }
    }
  }
end

Benchmark.bm(20) do |bm|
  n = Integer(ARGV.first || 10)
  bm.report('make document') { Example = make_document }
  ObjectSpace.garbage_collect
  bm.report('rehearsal') { n.times { Example.render }}
  ObjectSpace.garbage_collect
  bm.report('default') { n.times { Example.render }}
  ObjectSpace.garbage_collect
  bm.report('pretty=false') { n.times { Example.render(pretty: false) }}
  ObjectSpace.garbage_collect
  bm.report('validate=false') { n.times { Example.render(validate: false) }}
end
