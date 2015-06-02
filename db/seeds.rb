require 'csv'

# Product loader
require './lib/product_loader'

#  Seeds.rb
Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

puts 'Tax Categories'
Spree::TaxCategory.create!(name: 'Default', is_default: true)

def seed_path(fname)
  f = File.join(Rails.root, 'db', 'seed_data', fname)
  fail Errno::ENOENT "File #{f} does not exist" unless File.exist?(f)
  f
end

puts 'Suppliers'
File.open(seed_path('suppliers.txt')).each do |n|
  Spree::Supplier.create(name: n)
end

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

CategoryLoader.new(seed_path('categories.yml')).load

%w(color material brand upcharges).each do |r|
  puts r.humanize
  option_type = Spree::OptionType.create(name: r,
                                         presentation: r.humanize.pluralize)
  File.open(seed_path(r.pluralize + '.txt')).each do |n|
    Spree::OptionValue.create(name: n.parameterize,
                              presentation: n,
                              option_type: option_type)
  end
end

puts 'Imprint methods'
File.open(seed_path('imprint_methods.txt')).each do |n|
  Spree::ImprintMethod.create(name: n)
end

puts 'PMS Colors'
CSV.foreach(seed_path('pms_colors.csv'), headers: true, header_converters: :symbol) do |row|
  Spree::PmsColor.create(row.to_hash)
end

puts 'Sizes'
File.open(seed_path('sizes.txt')).each do |n|
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

puts 'Pages'
CSV.foreach(seed_path('pages.csv'), headers: true, header_converters: :symbol) do |row|
  page = Spree::Page.create(row.to_hash)
  page.stores << Spree::Store.first
  page.save!
end

# Load products
ActiveRecord::Base.descendants.each(&:reset_column_information)
# ProductLoader.load_products('crown')
# ProductLoader.load_products('fields')
# ProductLoader.load_products('gemline')
# ProductLoader.load_products('high_caliber')
# ProductLoader.load_products('leeds')
ProductLoader.load_products('logomark')
# ProductLoader.load_products('norwood')
