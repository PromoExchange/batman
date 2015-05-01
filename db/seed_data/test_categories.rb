#!/usr/bin/env ruby
require 'yaml'
thing = YAML.load_file('categories.yml')

def load_object(o, d, p)
  o.each do |k, v|
    puts ' ' * (d * 2) + p + ':' + k
    load_object(v, d + 1, k) unless v.nil?
  end
end

load_object(thing,1,"")
