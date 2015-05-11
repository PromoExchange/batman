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

puts 'Categories'

class CategoryLoader

  def initialize(fname)
    @fname = fname
    @category_taxonomy = Spree::Taxonomy.where(name: 'Category').first_or_create
  end

  def load
    category_root = YAML.load_file(@fname)
    load_category_tree(category_root,@category_taxonomy)
  end

private
  def load_category_tree( branch , parent)
    branch.each do |k, v|
      puts "K:#{k}, V:#{v}"
      taxon = Spree::Taxon.create(name: k,
                                  parent_id: parent.id,
                                  taxonomy_id: @category_taxonomy.id )
      load_category_tree(v, taxon) unless v.nil?
    end
  end
end

CategoryLoader.new('./db/seed_data/categories.yml').load

puts 'Colors'
color_type = Spree::OptionType.create(name: 'Color', presentation: 'Colors')
File.open('./db/seed_data/colors.txt').each do |n|
  Spree::OptionValue.create(name: n, presentation: n, option_type: color_type)
end

puts 'Material'
material_type = Spree::OptionType.create(name: 'Material', presentation: 'Materials')
File.open('./db/seed_data/materials.txt').each do |n|
  Spree::OptionValue.create(name: n, presentation: n, option_type: material_type)
end

puts 'Brand'
brand_type = Spree::OptionType.create(name: 'Brand', presentation: 'Brands')
File.open('./db/seed_data/brands.txt').each do |n|
  line = n.strip.split(',')
  Spree::OptionValue.create(name: line[0], presentation: line[1], option_type: brand_type)
end

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
  { 'supplier@thepromoexchange.com': :supplier }
].each do |a|
  a.each do |k, v| # Icky
    user = Spree::User.create(email: k,
                              login: k,
                              password: 'spree123',
                              password_confirmation: 'spree123')
    user.spree_roles << Spree::Role.find_by_name(v)
    user.save!
  end
end
