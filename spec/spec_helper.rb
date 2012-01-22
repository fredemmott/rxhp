require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/rxhp/data/'
  add_filter '/hello.rb'
end
require 'rxhp'
