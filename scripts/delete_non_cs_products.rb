#!/usr/bin/env ruby
require File.expand_path('../../config/environment', __FILE__)

Spree::Product.where(custom_product: [nil, false]).destroy_all
