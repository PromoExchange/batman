require 'csv'
require 'open-uri'

puts 'Checking Leeds Cartons'

file_name = File.join(Rails.root, 'db/product_data/leeds.csv')

num_valid_cartons = 0
num_invalid_cartons = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  got_weight = true
  got_quantity = true
  got_length = true
  got_width = true
  got_depth = true

  puts '-------------------------'
  puts "Product: #{hashed[:itemno]}"
  if hashed[:standard_master_carton_actual_weight].nil?
    puts 'Missing weight'
    got_weight = false
  end

  if hashed[:standard_master_carton_quantity].nil?
    puts 'Missing quantity'
    got_quantity = false
  end

  if hashed[:standard_master_carton_length].nil?
    puts 'Missing length'
    got_length = false
  end

  if hashed[:standard_master_carton_width].nil?
    puts 'Missing width'
    got_width = false
  end

  if hashed[:standard_master_carton_depth].nil?
    puts 'Missing depth'
    got_depth = false
  end

  if got_weight == false ||
      got_quantity == false ||
      got_length == false ||
      got_width == false ||
      got_depth == false
    puts 'Invalid carton'
    num_invalid_cartons += 1
  else
    puts 'Valid carton'
    num_valid_cartons += 1
  end
  puts '-------------------------'
end

puts "Number of valid cartons #{num_valid_cartons}"
puts "Number of invalid cartons #{num_invalid_cartons}"
