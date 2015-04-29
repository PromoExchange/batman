# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email

[
  Country,
  Supplier,
].each do |m|
  ActiveRecord::Base.connection.execute(
            "TRUNCATE TABLE #{m.table_name} RESTART IDENTITY;")
end

CSV.foreach('./db/seed_data/countries.csv', headers: true) do |row|
  Country.create!(row.to_hash)
  # puts row['code_numeric']
end

CSV.foreach('./db/seed_data/suppliers.csv', headers: true) do |row|
  Supplier.create!(row.to_hash)
  # puts row['name']
  # puts row['description']
end

# Add initial users
user = User.new :name => 'Supplier',
        :email => 'supplier@example.com',
        :password => 'password'
user.add_role :supplier
user.save!

user = User.new :name => 'Buyer',
        :email => 'buyer@example.com',
        :password => 'password'
user.add_role :buyer
user.save!

user = User.new :name => 'Seller',
        :email => 'seller@example.com',
        :password => 'password'
user.add_role :seller
user.save!
