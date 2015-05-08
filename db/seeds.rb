require 'csv'
require 'yaml'

# Clear out old seed data
[
  Country,
  Color,
  # Supplier,
  Category,
  Material
].each do |m|
  ActiveRecord::Base.connection.execute(
    "TRUNCATE TABLE #{m.table_name} RESTART IDENTITY;")
end

# At least one user with admin rights, values taken from secrets
user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email

# User.find_or_create_by!(email: 'supplier@example.com') do |u|
#   u.password = 'password'
#   u.name = 'Supplier'
#   u.password_confirmation = 'password'
#   user.add_role :supplier
# end
#
# User.find_or_create_by!(email: 'buyer@example.com') do |u|
#   u.password = 'password'
#   u.name = 'Buyer'
#   u.password_confirmation = 'password'
#   user.add_role :buyer
# end
#
# User.find_or_create_by!(email: 'seller@example.com') do |u|
#   u.password = 'password'
#   u.name = 'Seller'
#   u.password_confirmation = 'password'
#   user.add_role :seller
# end

# Countries
CSV.foreach('./db/seed_data/countries.csv', headers: true) do |row|
  Country.create!(row.to_hash)
  # puts row['code_numeric']
end

# Some suppliers
# CSV.foreach('./db/seed_data/suppliers.csv', headers: true) do |row|
#   Supplier.create!(row.to_hash)
#   # puts row['name']
#   # puts row['description']
# end

# Colors
CSV.foreach('./db/seed_data/product_colors.csv', headers: true) do |row|
  Color.create!(row.to_hash)
  # puts row['name']
  # puts row['description']
end

# Materials
CSV.foreach('./db/seed_data/materials.csv', headers: true) do |row|
  Material.create!(row.to_hash)
  # puts row['name']
  # puts row['description']
end

# Categories
# Create tree and related (parents) via a join table

cf = YAML.load_file('./db/seed_data/categories.yml')

def load_category_tree(o, p)
  o.each do |k, v|
    pa = Category.find_or_create_by(name: k, parent_id: p.id)
    # puts "#{p.id} : #{pa.id}"
    load_category_tree(v, pa) unless v.nil?
  end
end

r = Category.create name: 'root', parent_id: -1
load_category_tree(cf, r)


Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
