def add_pms_color(supplier, imprint_method, name , pantone, hex)
  pms_color = Spree::PmsColor.where(
    name: name,
    pantone: pantone,
    hex: hex
  ).first_or_create

  Spree::PmsColorsSupplier.where(
    pms_color: pms_color,
    display_name: pantone,
    supplier: supplier,
    imprint_method: imprint_method
  ).first_or_create
end

def wrap_string(string)
  "\"#{string.gsub(/\"/, '""')}\""
end

namespace :dc do
  # Fixes
  namespace :fix do
    desc 'Delete all existing prebids'
    task delete_prebids: :environment do
      Spree::Prebid.destroy_all
    end

    desc 'Get invalid CSV'
    task invalid_report: :environment do
      puts 'factory,name,sku,num_imprints,num_prices,num_colors'
      Spree::Product.where(state: 'invalid').each do |product|
        line = ''
        line << wrap_string(product.supplier.name) << ','
        line << wrap_string(product.name) << ','
        line << wrap_string(product.sku) << ','

        line << Spree::ImprintMethodsProduct.where(product: product).count.to_s << ','

        line << Spree::VolumePrice.where(variant: product.master).count.to_s << ','

        line << Spree::ColorProduct.where(product: product).count.to_s << ','
        puts line
      end
    end

    desc 'Fix AIO Drives'
    task aio: :environment do
      supplier = Spree::Supplier.where(name: 'All in One').first_or_create
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create

      add_these_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Brown', '498 C', '#00664f'],
        ['Dark Green', '336 C', '#00664f'],
        ['Green', '348 C', '#00843d'],
        ['Light Blue', 'Light Blue', '#add8e6'],
        ['Maroon', '202 C', '#862633'],
        ['Gold', '123 C', '#ffc72c'],
        ['Silver', '877 C', '#8a8d8f'],
        ['Navy Blue', '281 C', '#00205b'],
        ['Orange', '21 C', '#fe5000'],
        ['Pink', 'Rhodamine', '#e10098'],
        ['Purple', '259 C', '#6d2077'],
        ['Red', '186 C', '#c8102e'],
        ['Royal Blue', 'Reflex Blue C', '#001489'],
        ['Teal', '321 C', '#008c95'],
        ['Violet', 'Violet C', '#440099'],
        ['Yellow', 'Yellow C', '#fedd00']
      ]
      add_these_colors.each do |color|
        add_pms_color(
          supplier,
          imprint_method,
          color[0],
          color[1],
          color[2]
        )
      end

      product_guids = [
        'E41E27A5-DCE5-4648-9042-6527DBD4A56F',
        '50C83239-E2AA-4297-B445-884392332F0D'
      ]

      product_guids.each do |product_guid|
        product = Spree::Product.where(supplier_item_guid: product_guid).first

        next unless product

        product.loading

        Spree::ImprintMethodsProduct.where(
          imprint_method: imprint_method,
          product: product
        ).first_or_create

        product.check_validity!
        product.loaded if product.state == 'loading'
      end
    end

    desc 'Fix Garyline'
    task garyline: :environment do
      supplier = Spree::Supplier.where(name: 'Garyline').first_or_create
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create

      add_these_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Yellow', 'Yellow C', '#fedd00'],
        ['Gold', '123 C', '#ffc72c'],
        ['Orange', '1495 C', '#ff8f1c'],
        ['Warm Red', '485 C', '#da291c'],
        ['Red', '186 C', '#c8102e'],
        ['Maroon', '202 C', '#862633'],
        ['Pink', 'Rhodamine', '#e10098'],
        ['Gray', 'Gray 9', '#75787b'],
        ['Violet', 'Violet C', '#440099'],
        ['Royal Blue', 'Reflex Blue C', '#001489'],
        ['Navy Blue', '281 C', '#00205b'],
        ['Cyan', '299 C', '#00a3e0'],
        ['Process Blue', 'Process Blue', '#0085ca'],
        ['Teal', '321 C', '#008c95'],
        ['Green', '348 C', '#00843d'],
        ['Dark Green', '336 C', '#00664f'],
        ['Brown', '498 C', '#00664f'],
        ['Matte Silver', '877 C', '#8a8d8f'],
        ['Matte Gold', '873 C', '#866d4b'],
        ['Orange', '21 C', '#fe5000'],
        ['Lime Green', '375 C', '#97d700']
      ]
      add_these_colors.each do |color|
        add_pms_color(
          supplier,
          imprint_method,
          color[0],
          color[1],
          color[2]
        )
      end

      products = Spree::Product.where(supplier: supplier)

      products.each do |product|
        product.loading

        Spree::ImprintMethodsProduct.where(
          imprint_method: imprint_method,
          product: product
        ).first_or_create

        product.check_validity!
        product.loaded if product.state == 'loading'
      end
    end

    desc 'Fix Evans'
    task evans: :environment do
      supplier = Spree::Supplier.where(name: 'Evans Manufacturing, Inc.').first_or_create
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create

      add_these_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Ivory', '7527', '#d6d2c4'],
        ['Grey', 'Cool Gray 10', '#63666a'],
        ['Yellow', '123 C', '#ffc72c'],
        ['Orange', '166 C', '#e35205'],
        ['Red', '186 C', '#c8102e'],
        ['Burgundy', '202 C', '#862633'],
        ['Purple', '259 C', '#6d2077'],
        ['Royal Blue', '286 C', '#0033a0'],
        ['Dark Blue', '289 C', '#0c2340'],
        ['Process Blue', '307 C', '#0085ca'],
        ['Dark Green', '343 C', '#115740'],
        ['Green', '343 C', '#00843d'],
        ['Teal', '3278 C', '#009b77'],
        ['Brown', '476 C', '#4e3629'],
        ['Gold', '872 C', '#85714d'],
        ['Silver', '877 C', '#8a8d8f'],
        ['Pink', '189 C', '#f8a3bc'],
        ['Neon Pink', '806 C', '#ff3eb5']
      ]

      add_these_colors.each do |color|
        add_pms_color(
          supplier,
          imprint_method,
          color[0],
          color[1],
          color[2]
        )
      end

      products = Spree::Product.where(supplier: supplier)

      products.each do |product|
        product.loading

        Spree::ImprintMethodsProduct.where(
          imprint_method: imprint_method,
          product: product
        ).first_or_create

        product.check_validity!
        product.loaded if product.state == 'loading'
      end
    end
  end

  namespace :product do
    desc 'Reload All products in database'
    task reload_all: :environment do
      Spree::Product.all.each do |product|
        product.loading
        Resque.enqueue(
          ProductLoad,
          supplier_item_guid: product.supplier_item_guid
        )
      end
    end

    desc 'Reload invalid products in database'
    task reload_invalid: :environment do
      Spree::Product.where(state: 'invalid').each do |product|
        product.loading
        Resque.enqueue(
          ProductLoad,
          supplier_item_guid: product.supplier_item_guid
        )
      end
    end

    desc 'Reload loading products in database'
    task reload_loading: :environment do
      Spree::Product.where(state: 'loading').each do |product|
        product.loading
        Resque.enqueue(
          ProductLoad,
          supplier_item_guid: product.supplier_item_guid
        )
      end
    end

    desc 'Set product validity'
    task validity: :environment do
      Spree::Product.all.map(&:check_validity!)
    end
  end

  # Maps
  namespace :maps do
    namespace :option do
      desc 'Export option mappings'
      task export: :environment do
        CSV.open(File.join(Rails.root,'db/maps/option_export.csv'),'wb') do |csv|
          csv << Spree::OptionMapping.attribute_names
          Spree::OptionMapping.all.each do |option_map|
            csv << option_map.attributes.values
          end
        end
      end

      desc 'Import option mappings'
      task import: :environment do
        begin
          import_file = File.join(Rails.root,'db/maps/option_import.csv')
          fail "Option Mapping Import file is missing: #{import_file}" unless File.exists?(import_file)
          Spree::OptionMapping.destroy_all
          count = 1
          CSV.foreach(import_file, headers: true, header_converters: :symbol) do |row|
            hashed = row.to_hash
            puts "Count:#{count}"
            Spree::OptionMapping.create(hashed)
            count += 1
          end
        rescue => e
          puts "ERROR: #{e.to_s}"
        end
      end
    end
  end

  # Categories
  namespace :category do
    desc 'Reload DC Categories'
    task reload: :environment do
      category_taxonomy = Spree::Taxonomy.where(name: 'Categories').first_or_create
      Spree::Taxon.where(taxonomy_id: category_taxonomy.id).destroy_all

      category_taxonomy = Spree::Taxonomy.where(name: 'Categories').first_or_create
      category_taxon = Spree::Taxon.where(
        name: 'Categories',
        parent_id: nil,
        taxonomy_id: category_taxonomy.id
      ).first_or_create

      tree = Spree::DcCategory.category_tree
      tree.each do |parent|
        parent_taxon = Spree::Taxon.create(
          name: parent.name,
          dc_category_guid: parent.guid,
          parent_id: category_taxon.id,
          taxonomy_id: category_taxonomy.id
        )
        parent.children.each do |child|
          Spree::Taxon.create(
            name: child.name,
            dc_category_guid: child.guid,
            parent_id: parent_taxon.id,
            taxonomy_id: category_taxonomy.id
          )
        end
      end
    end
  end
end
