# Product loader
require './lib/product_loader'

#  Seeds.rb
Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

puts 'Tax Categories'
Spree::TaxCategory.create!(name: 'Default', is_default: true)

puts 'Categories'

class CategoryLoader
  def initialize(fname)
    @fname = fname
    @category_taxonomy = Spree::Taxonomy.where(name: 'Category').first_or_create
  end

  def load
    category_root = YAML.load_file(@fname)
    load_category_tree(category_root, @category_taxonomy)
  end

  private

  def load_category_tree(branch, parent)
    branch.each do |k, v|
      taxon = Spree::Taxon.create(name: k,
                                  parent_id: parent.id,
                                  taxonomy_id: @category_taxonomy.id)
      load_category_tree(v, taxon) unless v.nil?
    end
  end
end

CategoryLoader.new('./db/seed_data/categories.yml').load

[
  ['color', './db/seed_data/colors.txt'],
  ['material', './db/seed_data/materials.txt'],
  ['brand', './db/seed_data/brands.txt'],
  ['imprint', './db/seed_data/imprint_methods.txt']
].each do |r|
  puts r[0].humanize
  option_type = Spree::OptionType.create(name: r[0],
                                         presentation: r[0].humanize.pluralize)
  File.open(r[1]).each do |n|
    Spree::OptionValue.create(name: n.parameterize,
                              presentation: n,
                              option_type: option_type)
  end
end

puts 'Sizes'
File.open('./db/seed_data/sizes.txt').each do |n|
  line = n.strip.split(',')

  option_type = Spree::OptionType.create(name: (line[0] + '_size').parameterize,
                                         presentation: line[0] + ' Size')

  line[1].split('|').each do |v|
    Spree::OptionValue.create(name: v.parameterize,
                              presentation: v,
                              option_type: option_type)
  end
end

puts 'Roles'
Spree::Role.where(name: 'admin').first_or_create
Spree::Role.where(name: 'user').first_or_create
Spree::Role.where(name: 'buyer').first_or_create
Spree::Role.where(name: 'seller').first_or_create
Spree::Role.where(name: 'supplier').first_or_create

puts 'Create Users'
[
  ['tim.varley@thepromoexchange.com', 'admin'],
  ['spencer.applegate@thepromoexchange.com', 'admin'],
  ['buyer@thepromoexchange.com', 'buyer'],
  ['seller@thepromoexchange.com', 'seller'],
  ['supplier@thepromoexchange.com', 'supplier']
].each do |r|
  user = Spree::User.create(email: r[0],
                            login: r[0],
                            password: 'spree123',
                            password_confirmation: 'spree123')
  user.spree_roles << Spree::Role.find_by_name(r[1])
  user.save!
end

# Load products
# ActiveRecord::Base.descendants.each(&:reset_column_information)
# ProductLoader.load_products('norwood_writing_instruments')
