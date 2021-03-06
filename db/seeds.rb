require 'csv'

Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

puts 'Tax Categories'
Spree::TaxCategory.create!(name: 'Default', is_default: true)
usa_country = Spree::Country.where(iso3: 'USA').first

# For each state, create a tax zone with a single member
usa_country.states.each do |s|
  z = Spree::Zone.create(name: s.name, description: "Tax zone for #{s.name}")
  Spree::ZoneMember.create(zoneable_id: s.id, zoneable_type: 'Spree::State', zone_id: z.id)
end

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

  def self.load_taxon_tree(branch, parent, taxonomy)
    branch.each do |k, v|
      taxon = Spree::Taxon.create(name: k,
                                  parent_id: parent.id,
                                  taxonomy_id: taxonomy.id)
      load_taxon_tree(v, taxon, taxonomy) unless v.nil?
    end
  end
end

puts 'Upcharge types'
File.open(seed_path('upcharge_types.txt')).each do |n|
  Spree::UpchargeType.create(name: n.strip)
end

# puts 'Imprint methods'
# File.open(seed_path('imprint_methods.txt')).each do |n|
#   Spree::ImprintMethod.create(name: n.strip)
# end

# puts 'PMS Colors'
# CSV.foreach(seed_path('pms_colors.csv'), headers: true, header_converters: :symbol) do |row|
#   Spree::PmsColor.create(row.to_hash)
# end

puts 'Product Properties'
CSV.foreach(seed_path('product_properties.csv'), headers: true, header_converters: :symbol) do |row|
  Spree::Property.create(row.to_hash)
end

puts 'Roles'
Spree::Role.where(name: 'admin').first_or_create
Spree::Role.where(name: 'user').first_or_create
Spree::Role.where(name: 'buyer').first_or_create
Spree::Role.where(name: 'seller').first_or_create
Spree::Role.where(name: 'supplier').first_or_create

country = Spree::Country.where(iso3: 'USA').first
state = Spree::State.where(name: 'New York').first

puts 'Users'
[
  ['michael.goldstein@thepromoexchange.com', 'admin'],
  ['kevin.widmaier@thepromoexchange.com', 'buyer'],
  ['connor.labarge@thepromoexchange.com', 'buyer'],
  ['tim.varley@thepromoexchange.com', 'admin'],
  ['spencer.applegate@thepromoexchange.com', 'admin'],
  ['buyer@thepromoexchange.com', 'buyer'],
  ['seller@thepromoexchange.com', 'seller'],
  ['buyer2@thepromoexchange.com', 'buyer'],
  ['seller2@thepromoexchange.com', 'seller']
].each do |r|
  user = Spree::User.create(email: r[0],
                            login: r[0],
                            password: 'spree123',
                            password_confirmation: 'spree123')
  user.spree_roles << Spree::Role.find_by_name(r[1])
  user.generate_spree_api_key!

  user.ship_address = Spree::Address.create(
    company: 'Shippy',
    firstname: 'Donald',
    lastname: 'Duck',
    address1: '123 PromoExchange Road',
    city: 'Tarrytown',
    zipcode: '10591',
    state_id: state.id,
    country_id: country.id,
    phone: '555-555-5555'
  )

  user.bill_address = Spree::Address.create(
    company: 'Billy',
    firstname: 'Donald',
    lastname: 'Duck',
    address1: '123 PromoExchange Road',
    city: 'Tarrytown',
    zipcode: '10591',
    state_id: state.id,
    country_id: country.id,
    phone: '555-555-5555'
  )

  user.save!
  user.confirm!
end
