#!/usr/bin/env ruby
require 'yaml'
thing = YAML.load_file('categories.yml')

def load_object(o,d)
  o.each do |k,v|
    load_object(v,d+1) unless v.nil?
    puts ' '* (d*2) + k
  end
end

load_object(thing,1)
