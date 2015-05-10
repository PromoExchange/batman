# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

# Loads seed data out of default dir
SpreeCore::Engine.load_seed if defined?(SpreeCore)

puts 'Roles'
Spree::Role.where(name: 'admin').first_or_create
Spree::Role.where(name: 'user').first_or_create
Spree::Role.where(name: 'buyer').first_or_create
Spree::Role.where(name: 'seller').first_or_create
Spree::Role.where(name: 'supplier').first_or_create

puts 'Create Users'
[
  { 'tim.varley@thepromoexchange.com': :admin },
  { 'spencer.applegate@thepromoexchange.com': :admin  },
  { 'buyer@thepromoexchange.com': :buyer },
  { 'seller@thepromoexchange.com': :seller },
  { 'suppler@thepromoexchange.com': :supplier }
].each do |a|
  a.each do |k, v|
    user = Spree::User.create(email: k,
                              login: k,
                              password: 'spree123',
                              password_confirmation: 'spree123')
    user.spree_roles << Spree::Role.find_by_name(v)
    user.save!
  end
end
