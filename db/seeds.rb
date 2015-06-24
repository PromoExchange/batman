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
  fail StandardError "File #{f} does not exist" unless File.exist?(f)
  f
end

puts 'Taxons'
class TaxonLoader
  def self.load_categories(file_name)
    category_taxonomy = Spree::Taxonomy.where(name: 'Categories').first_or_create
    category_root = YAML.load_file(file_name)
    load_taxon_tree(category_root, category_taxonomy, category_taxonomy)
  end

  def self.load_colors(file_name)
    color_taxonomy = Spree::Taxonomy.where(name: 'Colors').first_or_create
    File.open(file_name).each do |color|
      Spree::Taxon.create(
        name: color.strip,
        parent_id: Spree::Taxon.where(name: 'Colors').first.id,
        taxonomy_id: color_taxonomy.id)
    end
  end

  def self.load_taxon_tree(branch, parent, taxonomy)
    branch.each do |k, v|
      taxon = Spree::Taxon.create(name: k,
                                  parent_id: parent.id,
                                  taxonomy_id: taxonomy.id)
      load_taxon_tree(v, taxon, taxonomy) unless v.nil?
    end
  end
end

TaxonLoader.load_categories(seed_path('categories.yml'))
TaxonLoader.load_colors(seed_path('px_colors.txt'))

%w(material brand).each do |r|
  puts r.humanize
  option_type = Spree::OptionType.create(name: r,
                                         presentation: r.humanize.pluralize)
  File.open(seed_path(r.pluralize + '.txt')).each do |n|
    Spree::OptionValue.create(name: n.parameterize,
                              presentation: n,
                              option_type: option_type)
  end
end

puts 'Upcharge types'
File.open(seed_path('upcharge_types.txt')).each do |n|
  Spree::UpchargeType.create(name: n.strip)
end

puts 'Imprint methods'
File.open(seed_path('imprint_methods.txt')).each do |n|
  Spree::ImprintMethod.create(name: n)
end

puts 'PMS Colors'
CSV.foreach(seed_path('pms_colors.csv'), headers: true, header_converters: :symbol) do |row|
  Spree::PmsColor.create(row.to_hash)
end

puts 'Supplier Colors'
ot = Spree::OptionType.create(name: 'supplier_color'.parameterize,
                              presentation: 'Supplier Color')
CSV.foreach(seed_path('supplier_color_conversions.csv'), headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  ov = Spree::OptionValue.new(name: hashed[:catalog_data].parameterize,
                              presentation: hashed[:catalog_data],
                              option_type: ot)

  ov.taxons << Spree::Taxon.where(permalink: "colors/#{hashed[:px_color_1].to_url}").first if hashed[:px_color_1]
  ov.taxons << Spree::Taxon.where(permalink: "colors/#{hashed[:px_color_2].to_url}").first if hashed[:px_color_2]
  ov.taxons << Spree::Taxon.where(permalink: "colors/#{hashed[:px_color_3].to_url}").first if hashed[:px_color_3]
  ov.save!
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

puts 'Users'
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

%w(
  gemline
  crown
  fields
  high_caliber
  leeds
  logomark
  norwood
  primeline
  starline
  vitronic
).each { |supplier| ProductLoader.load('products', supplier) }

%w(
  vitronic
).each { |supplier| ProductLoader.load('upcharges', supplier) }
