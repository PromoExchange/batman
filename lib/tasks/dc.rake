def add_pms_color(supplier, imprint_method, name, pantone, hex)
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

    desc 'Fix American Accent Napkins'
    task american_accents: :environment do
      supplier = Spree::Supplier.where(name: 'American Accents').first_or_create
      screen_print = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create

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
          screen_print,
          color[0],
          color[1],
          color[2]
        )
      end

      napkins = [
        ['White', 'A04A0EF9-8CB3-4771-B6EC-40E0A7EFCC6C'],
        ['White', 'AFC06A67-02E1-429E-B18D-AE5CD89BEFD8'],
        ['White', 'D662D322-CFE8-4E03-9759-B6FD038818F5'],
        ['Aqua', 'EB32B66A-D8FC-4750-90E3-6833A9AC2EC1'],
        ['Black', 'DB14664C-4E32-481F-9C8F-FAC707105148'],
        ['Blue', '145263F1-1223-46CE-A1DA-89A7559FBE83'],
        ['Burgundy', '22B65D60-51EC-444F-B587-2380049B6C94'],
        ['Green', 'C9524625-0EEA-4408-ACEB-67843F5178D8'],
        ['Ivory', 'B608D6FE-A59E-4523-BF9F-C1636A853245'],
        ['Light Blue', '1D2725A7-4D27-44B9-A4E8-C7F87160A32E'],
        ['Red', '01E1E0E3-3C23-4B76-BA2B-BA9A3DB392DD'],
        ['Light Green', '1389E233-CEAC-43B2-B494-82C71FA9CACD'],
        ['Magenta', '58259221-0DF9-40E0-A74D-09584A958D65'],
        ['Orange', '372E423D-F43C-489A-937E-BB480BD1CBBA'],
        ['Pink', 'C04880F3-7C51-4C64-85AD-8EC609927B73'],
        ['Silver', 'A56895E6-1040-4258-A9D4-56A2314E9E89'],
        ['Teal', '2179CB1D-3974-4716-BE92-7CAD6E7E7D5A'],
        ['Yellow', 'AA17430A-07AC-4425-9018-FB3D96D34AB0'],
        ['Almost Linen', '493C329F-C886-4C4E-B99C-323F184B22C5'],
        ['White', 'BE7F028C-1AAA-46E5-AB8A-5E1DAE49FD02'],
        ['Black', '4B39FA22-3875-49B7-BB9A-E2D2DE12B5B7'],
        ['Dark Blue', '5B631858-7DC2-4BCA-9D91-81797E1B3289'],
        ['Green', '66A2C90F-239C-497C-876D-7AE0D9F65BB4'],
        ['Purple', '36BA868D-DA23-4405-A850-853ECCCC6BC5'],
        ['Red', '2F8B6DC1-300C-46E2-B519-5DF5AD3957E4'],
        ['Silver', '32B622B8-702E-41F9-9670-638F5078F82C'],
        ['Yellow', '462E6EB5-1DA7-492A-A9AB-4211E3ABF341'],
        ['White', '3316212A-582B-40C6-B32A-72ABCB1171C2'],
        ['Black', '08AB4314-51D0-4E24-BE48-02280640EC04'],
        ['Dark Blue', 'CAE74FF0-8385-4E33-BA7A-5AFF490F3DD9'],
        ['Ivory', 'F2650B0B-423C-422C-BFD5-8536E89827B7'],
        ['Purple', 'FD4CA05B-BF04-4952-AA44-433B9C93A3C3'],
        ['Red', 'DBA558ED-8639-43CE-A572-266499A41899'],
        ['Silver', 'D2147037-4FF7-4434-92B7-194EA2E2C4A3'],
        ['Yellow', '86879B90-66AC-4443-BF2B-B6B73884C963'],
        ['Almost Linen', 'DB71EA4C-FAC1-4D04-ACFE-219E5FE5F23C'],
        ['White', '54B32019-06D6-40AB-89D1-461F422BD9A2'],
        ['White', '2DD13B5F-B380-492E-9CC2-16213BD37F15'],
        ['Purple', '68ED7485-39C6-44D7-9833-B908450412BF'],
        ['Ivory', '3BFBA591-56E1-4ABA-A1B2-092CAE179F91'],
        ['Green', 'F5893E00-96E6-4CE1-806D-CD06163B0C85'],
        ['Natural', 'A15276A3-CC19-42D1-8823-B4DC1D41B913'],
        ['Chocolate', '41D407BB-E6F9-4C2E-B826-AFD8D1D3BC6D'],
        ['Dark Blue', '53A020FC-2360-4235-BFB7-5D166A1BB24C'],
        ['Dark Green', '93D34317-AA3D-47E7-A815-3DE4C3C953F4']
      ]

      napkins.each do |napkin|
        product = Spree::Product.where(supplier_item_guid: napkin[1]).first
        next if product.nil?

        product.loading

        Spree::ImprintMethodsProduct.where(
          imprint_method: screen_print,
          product: product
        ).first_or_create

        Spree::ColorProduct.where(
          product: product,
          color: napkin[0]
        ).first_or_create

        product.check_validity!
        product.loaded if product.state == 'loading'
      end
    end

    desc 'Fix SanMar Apparel'
    task sanmar: :environment do
      supplier = Spree::Supplier.where(name: 'SanMar').first_or_create
      screen_print = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      embroidery = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create

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
          screen_print,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          embroidery,
          color[0],
          color[1],
          color[2]
        )
      end

      products = Spree::Product.where(supplier: supplier)

      products.each do |product|
        product.loading

        Spree::ImprintMethodsProduct.where(
          imprint_method: screen_print,
          product: product
        ).first_or_create

        Spree::ImprintMethodsProduct.where(
          imprint_method: embroidery,
          product: product
        ).first_or_create

        product.check_validity!
        product.loaded if product.state == 'loading'
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
    namespace :pms do
      desc 'Export PMS colors'
      task export: :environment do
        CSV.open(File.join(Rails.root, 'db/maps/pmscolor_export.csv'), 'wb') do |csv|
          csv << %w(name display_name pantone hex)
          Spree::PmsColor.all.each do |pms_color|
            row = []
            row << pms_color.name
            row << pms_color.display_name
            row << pms_color.pantone
            row << pms_color.hex
            csv << row
          end
        end
      end

      desc 'Import PMS Colors'
      task import: :environment do
        begin
          import_file = File.join(Rails.root, 'db/maps/pmscolor_import.csv')
          fail "PMS Color import file is missing: #{import_file}" unless File.exist?(import_file)
          Spree::PmsColor.destroy_all
          CSV.foreach(import_file, headers: true, header_converters: :symbol) do |row|
            hashed = row.to_hash
            Spree::PmsColor.create(hashed)
          end
        rescue => e
          puts "ERROR: #{e}"
        end
      end

      desc 'Export PMS by Factory/Imprint colors'
      task export_factory: :environment do
        CSV.open(File.join(Rails.root, "db/maps/pmscolor_by_factory_export-#{Time.zone.today}.csv"), 'wb') do |csv|
          csv << %w(factory imprint_method name display_name pantone hex)
          data = ''
          Spree::Supplier.all.each do |factory|
            Spree::PmsColorsSupplier.where(supplier: factory).each do |pms_color_supplier|
              imprint_method = Spree::ImprintMethod.find(pms_color_supplier.imprint_method_id)
              pms_color = Spree::PmsColor.find(pms_color_supplier.pms_color_id)
              row = []
              row << factory.name
              row << imprint_method.name
              row << pms_color.name
              row << pms_color.display_name
              row << pms_color.pantone
              row << pms_color.hex
              csv << row
            end
          end
        end
      end

      desc 'Import PMS by Factory/Imprint colors'
      task import_factory: :environment do
        begin
          import_file = File.join(Rails.root, 'db/maps/pmscolor_by_factory_import.csv')
          fail "PMS Color by factory import file is missing: #{import_file}" unless File.exist?(import_file)
          CSV.foreach(import_file, headers: true, header_converters: :symbol) do |row|
            hashed = row.to_hash
            supplier = Spree::Supplier.where(name: hashed[:factory]).first_or_create

            next if hashed[:display_name].blank?

            if supplier.nil?
              puts "Failed to local supplier #{hashed[:factory]}"
              next
            end

            imprint = Spree::ImprintMethod.where(name: hashed[:imprint_method].strip).first_or_create

            if imprint.nil?
              puts "Failed to find imprint #{hashed[:imprint_method]}"
              next
            end

            pms_color = Spree::PmsColor.where(name: hashed[:name]).first_or_create
            if pms_color.nil?
              puts "Failed to find pms color #{hashed[:name]}"
              next
            end

            pms_colors_supplier = Spree::PmsColorsSupplier.where(
              pms_color: pms_color,
              supplier: supplier,
              imprint_method: imprint
            ).first

            if pms_colors_supplier.nil?
              pms_colors_supplier = Spree::PmsColorsSupplier.where(
                pms_color: pms_color,
                supplier: supplier,
                imprint_method: imprint,
                display_name: hashed[:display_name]
              ).first_or_create
            end

            pms_colors_supplier.update_attributes!(display_name: hashed[:display_name])

            pms_color.update_attributes!(
              pantone: hashed[:pantone],
              hex: hashed[:hex],
              display_name: hashed[:display_name]
            )
          end
        rescue => e
          puts "ERROR: #{e}"
        end

        CSV.open(File.join(Rails.root, "db/maps/pmscolor_by_factory_export-#{Time.zone.today}.csv"), 'wb') do |csv|
          csv << %w(supplier_name imprint_method name display_name pantone hex)
          data = ''
          Spree::Supplier.all.each do |factory|
            Spree::PmsColorsSupplier.where(supplier: factory).each do |pms_color_supplier|
              imprint_method = Spree::ImprintMethod.find(pms_color_supplier.imprint_method_id)
              pms_color = Spree::PmsColor.find(pms_color_supplier.pms_color_id)
              row = []
              row << factory.name
              row << imprint_method.name
              row << pms_color.name
              row << pms_color.display_name
              row << pms_color.pantone
              row << pms_color.hex
              csv << row
            end
          end
        end
      end
    end

    namespace :option do
      desc 'Export option mappings'
      task export: :environment do
        CSV.open(File.join(Rails.root, 'db/maps/option_export.csv'), 'wb') do |csv|
          csv << %w(dc_acct_num dc_name px_name do_not_save)
          Spree::OptionMapping.all.each do |option_map|
            row = []
            row << option_map.dc_acct_num
            row << option_map.dc_name.strip
            row << option_map.px_name
            row << option_map.do_not_save
            csv << row
          end
        end
      end

      desc 'Import option mappings'
      task import: :environment do
        begin
          import_file = File.join(Rails.root, 'db/maps/option_import.csv')
          fail "Option Mapping import file is missing: #{import_file}" unless File.exist?(import_file)
          Spree::OptionMapping.destroy_all
          count = 1
          CSV.foreach(import_file, headers: true, header_converters: :symbol) do |row|
            hashed = row.to_hash
            Spree::OptionMapping.create(hashed)
            count += 1
          end
        rescue => e
          puts "ERROR: #{e}"
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
