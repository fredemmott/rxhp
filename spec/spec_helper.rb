require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/rxhp/data/'
end
require 'rxhp'
