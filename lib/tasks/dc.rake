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

    desc 'Create cartons for all products'
    task create_cartons: :environment do
      Spree::Product.all.each do |p|
        p.build_carton
        p.save!
      end
    end

    desc 'Fix Fields PMS Colors'
    task fields: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '100156').first
      return if supplier.nil?
      screen_print = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      four_color_process_imprint = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create

      add_these_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Cool Gray', 'Gray 9', '#75787b'],
        ['Gray', '425 C', '#54585a'],
        ['Purple', '273 C', '#24135f'],
        ['Light Purple', '527 C', '#8031a7'],
        ['Navy', '282 C', '#041e42'],
        ['Reflex Blue', 'Reflex Blue', '#001489'],
        ['Dark Blue', '294 C', '#002f6c'],
        ['Blue', '286 C', '#0033a0'],
        ['Royal Blue', '300 C', '#005eb8'],
        ['Teal', '300 C', '#008675'],
        ['Dark Green', '357 C', '#215732'],
        ['Forest Green', '349 C', '#046a38'],
        ['Green', '354 C', '#00b140'],
        ['Yellow', '109 C', '#ffd100'],
        ['Athletic Gold', '123 C', '#ffc72c'],
        ['Orange', '172 C', '#fa4616'],
        ['Orange', '021 C', '#fe5000'],
        ['Pink', '211 C', '#f57eb6'],
        ['Bright Red', '185 C', '#e4002b'],
        ['Red', '485 C', '#da291c'],
        ['Burgundy', '209 C', '#6f263d'],
        ['Brown', '469 C', '#693f23'],
        ['Metallic Gold', '871 C', '#84754e'],
        ['Metallic Silver', '877 C', '#8d9092']
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
          four_color_process_imprint,
          color[0],
          color[1],
          color[2]
        )
      end
    end

    desc 'Fix Vitronic PMS Colors'
    task vitronic: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '101715').first
      return if supplier.nil?
      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create

      screen_print_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Navy Blue', '281 C', '#00205b'],
        ['Process Blue', 'Process Blue', '#0085ca'],
        ['Navy Blue', '281 C', '#00205b'],
        ['Reflex Blue', 'Reflex Blue', '#001489'],
        ['Royal Blue', '286 C', '#0033a0'],
        ['Royal Blue', '286 C', '#0033a0'],
        ['Brown', '476 C', '#4e3629'],
        ['Burgundy', '202 C', '#862633'],
        ['Copper', '876 C', '#8b634b'],
        ['Athletic Gold', '123 C', '#ffc72c'],
        ['Metallic Gold', '873 C', '#866d4b'],
        ['Gray', '429 C', '#a2aaad'],
        ['Forest Green', '3435 C', '#154734'],
        ['Kelly Green', '356 C', '#007a33'],
        ['Teal', '320 C', '#009ca6'],
        ['Orange', '151 C', '#ff8200'],
        ['Pink', '211 C', '#f57eb6'],
        ['Purple', '268 C', '#582c83'],
        ['Red', '186 C', '#c8102e'],
        ['Warm Red', '032 C', '#ef3340'],
        ['Metallic Silver', '877 C', '#8d9092'],
        ['Yellow', '115 C', '#fdda24']
      ]
      screen_print_colors.each do |color|
        add_pms_color(
          supplier,
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
      end

      image_lock_imprint = Spree::ImprintMethod.where(name: 'Image Lock').first_or_create
      image_lock_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Light Blue', '2995 U', '#0d9ddb'],
        ['Navy Blue', '295 U', '#375172'],
        ['Process Blue', 'Process Blue', '#0085ca'],
        ['Reflex Blue', 'Reflex Blue', '#001489'],
        ['Royal Blue',  '293 U', '#235ba8'],
        ['Brown',  '477 U', '#7d6556'],
        ['Beige',  '155 U', '#f7c995'],
        ['Tan', '155 U', '#c1a67f'],
        ['Charcoal', '424 U', '#88898a'],
        ['Athletic Gold',  '109 U', '#ffc700'],
        ['Metallic Gold', '873 U', '#ae906f'],
        ['Gray', '422 U', '#9ea1a2'],
        ['Forest Green', '343 U', '#48655b'],
        ['Olive', '582 U', '#919145'],
        ['Teal', '327 U', '#008f85'],
        ['Maroon', '209 U', '#825864'],
        ['Orange', '021 U', '#ff6c2f'],
        ['Purple', '273 U', '#645d9b'],
        ['Red', '186 U', '#d2515e'],
        ['Cardinal Red', '200 U', '#bd4f5c'],
        ['Chili Red', '202 U', '#90585e'],
        ['Rubine', 'Rubine', '#db487e'],
        ['Metallic Silver', '877 U', '#b4b7b9'],
        ['Yellow', '107', '#8d9092']
      ]
      image_lock_colors.each do |color|
        add_pms_color(
          supplier,
          image_lock_imprint,
          color[0],
          color[1],
          color[2]
        )
      end

      hot_stamp_imprint = Spree::ImprintMethod.where(name: 'Hot Stamp').first_or_create
      hot_stamp_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Blue', '2728 C', '#0047bb'],
        ['Dark Blue', '2728 C', '#1b365d'],
        ['Navy Blue', '289 C', '#0c2340'],
        ['Process Blue', 'Process Blue', '#0085ca'],
        ['Brown', '476 C', '#4e3629'],
        ['Bison', '439 C', '#453536'],
        ['Dark Brown', '4625 C', '#4f2c1d'],
        ['Light Brown', '4635 C', '#946037'],
        ['Burgundy', '4635 C', '#782f40'],
        ['Dark Burgundy', '504 C', '#572932'],
        ['Grey', '431 C', '#5b6770'],
        ['Metallic Gold', '871 C', '#84754e'],
        ['Dark Green', '357 C', '#215732'],
        ['Light Green', '356 C', '#007a33'],
        ['Ivory', '1205 C', '#f8e08e'],
        ['Orange', '179 C', '#e03c31'],
        ['Pink', '673 C', '#d986ba'],
        ['Purple', '2587 C', '#8246af'],
        ['Dark Red', '188 C', '#76232f'],
        ['Light Red', '1805 C', '#af272f'],
        ['Metallic Silver', '877 C', '#8d9092'],
        ['Yellow', '124 C', '#eaaa00'],
        ['Light Yellow', '115 C', '#fdda24']
      ]
      hot_stamp_colors.each do |color|
        add_pms_color(
          supplier,
          hot_stamp_imprint,
          color[0],
          color[1],
          color[2]
        )
      end
    end

    desc 'Fix Logomark PMS Colors'
    task logomark: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '101044').first
      return if supplier.nil?

      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      value_mark_imprint = Spree::ImprintMethod.where(name: 'Valuemark').first_or_create
      logomark_imprint = Spree::ImprintMethod.where(name: 'Logomark').first_or_create
      vinyl_imprint = Spree::ImprintMethod.where(name: 'Vinyl').first_or_create
      transfer_imprint = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
      colorsplash_imprint = Spree::ImprintMethod.where(name: 'Colorsplash').first_or_create

      add_these_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Yellow', '012 C', '#ffd700'],
        ['Orange', '021 C', '#fe5000'],
        ['Red', '485 C', '#da291c'],
        ['Purple', '266 C', '#753bbd'],
        ['Burgundy', '202 C', '#862633'],
        ['Green', '347 C', '#009a44'],
        ['Royal Blue', '293 C', '#003da5'],
        ['Brown', '478 C', '#703f2a'],
        ['Light Gray', '428 C', '#703f2a'],
        ['Metallic Gold', '871 C', '#84754e'],
        ['Metallic Silver', '877 C', '#8d9092']
      ]
      add_these_colors.each do |color|
        add_pms_color(
          supplier,
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          value_mark_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          logomark_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          vinyl_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          transfer_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          colorsplash_imprint,
          color[0],
          color[1],
          color[2]
        )
      end
    end

    desc 'Fix Starline PMS Colors'
    task starline: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '100512').first
      return if supplier.nil?

      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      pad_print_imprint = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
      true_color_direct_imprint = Spree::ImprintMethod.where(name: 'True Color Direct Digital').first_or_create

      add_these_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Gold', '871 C', '#84754e'],
        ['Silver', '877 C', '#8d9092'],
        ['Red', '186 C', '#c8102e'],
        ['Maroon', '194 C', '#9b2743'],
        ['Violet', '2685 C', '#330072'],
        ['Process Blue', 'Process Blue', '#0085ca'],
        ['Reflex Blue', 'Reflex Blue', '#001489'],
        ['Navy Blue', '282 C', '#041e42'],
        ['Teal', '322 C', '#007377'],
        ['Light Green', '348 C', '#00843d'],
        ['Dark Green', '350 C', '#2c5234'],
        ['Yellow', '116 C', '#ffcd00'],
        ['Orange', '021 C', '#fe5000'],
        ['Grey', '423 C', '#898d8d']
      ]
      add_these_colors.each do |color|
        add_pms_color(
          supplier,
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          pad_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          true_color_direct_imprint,
          color[0],
          color[1],
          color[2]
        )
      end
    end

    desc 'Fix Primeline PMS Colors'
    task primeline: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '100334').first
      return if supplier.nil?

      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      pad_print_imprint = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
      embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create

      add_these_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Yellow', 'Yellow C', '#fedd00'],
        ['Medium Yellow', '116 C', '#ffcd00'],
        ['Dark Yellow', '1235 C', '#ffb81c'],
        ['Orange', '021 C', '#fe5000'],
        ['Light Red', '1787 C', '#f4364c'],
        ['Fire Red', '199 C', '#d50032'],
        ['Burgundy', '202 C', '#862633'],
        ['Maroon', '208 C', '#861f41'],
        ['Pink', '225 C', '#df1995'],
        ['Purple', '267 C', '#5f259f'],
        ['Light Blue', '2925 C', '#009cde'],
        ['Medium Blue', '287 C', '#003087'],
        ['Dark Blue', '281 C', '#00205b'],
        ['Process Blue', 'Process Blue', '#0085ca'],
        ['Reflex Blue', 'Reflex Blue', '#001489'],
        ['Teal', '327 C', '#008675'],
        ['Green', 'Green', '#00ab84'],
        ['Medium Green', '347 C', '#009a44'],
        ['Dark Green', '343 C', '#115740'],
        ['Brown', '4635 C', '#946037'],
        ['Grey', '423 C', '#898d8d'],
        ['Metallic Gold', '871 C', '#84754e'],
        ['Silver', '877 C', '#8d9092']
      ]
      add_these_colors.each do |color|
        add_pms_color(
          supplier,
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          pad_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          embroidery_imprint,
          color[0],
          color[1],
          color[2]
        )
      end
    end

    desc 'Fix Norwood PMS Colors'
    task norwood: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '100334').first
      return if supplier.nil?

      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create

      standard_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Red', '186 C', '#c8102e'],
        ['Maroon', '202 C', '#862633'],
        ['Burgundy', '208 C', '#861f41'],
        ['Magenta', '205 C', '#e0457b'],
        ['Pink', '211 C', '#f57eb6'],
        ['Cream', '1345 C', '#fdd086'],
        ['Orange', '172 C', '#fa4616'],
        ['Lemon', '114 C', '#fbdd40'],
        ['Athletic Gold', '116 C', '#ffcd00'],
        ['Teal', '327 U', '#008675'],
        ['Dark Teal', '316 C', '#004851'],
        ['Green', '355 C', '#009639'],
        ['Forest Green', '341 C', '#007a53'],
        ['Process Blue', 'Process Blue', '#0085ca'],
        ['Forest Green', '341 C', '#007a53'],
        ['Royal Blue', '293 C', '#003da5'],
        ['Reflex Blue', 'Reflex Blue', '#001489'],
        ['Navy Blue', '281 C', '#00205b'],
        ['Purple', '2587 C', '#8246af'],
        ['Brown', '1545 C', '#653819'],
        ['Charcoal Grey', '424 C', '#707372'],
        ['Met. Gold', '872 C', '#85714d'],
        ['Met. Silver', '877 C', '#8a8d8f'],
        ['Met. Copper', '876 C', '#8b634b'],
        ['Met. Green', '8283 C', '#499c93'],
        ['Met. Blue', '8203 C', '#3177a3'],
        ['Met. Magenta', '8085 C', '#a13769']
      ]
      standard_colors.each do |color|
        add_pms_color(
          supplier,
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
      end

      embroidery_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Light Gray', 'W Gray 3', '#bfb8af'],
        ['Gray', 'C Gray 7', '#97999b'],
        ['Dark Gray', '425', '#54585a'],
        ['Medium Brown', '476', '#4e3629'],
        ['Process Yellow', 'Process Yellow', '#fedd00'],
        ['Sunflow Yellow', '108', '#fedb00'],
        ['Yellow', '115', '#fdda24'],
        ['Light Gold', '1235', '#ffb81c'],
        ['Gold', '123', '#ffc72c'],
        ['Pumpkin Orange', '151', '#ff8200'],
        ['Orange', '165', '#ff671f'],
        ['Warm Red', 'Warm Red', '#f9423a'],
        ['Red', '186', '#c8102e'],
        ['Very Red', '200', '#ba0c2f'],
        ['Maroon', '201', '#9d2235'],
        ['Light Green', '802', '#44d62c'],
        ['Bright Green', '361', '#43b02a'],
        ['Royal Blue', '293', '#003da5'],
        ['Process Blue', 'Process Blue', '#0085ca'],
        ['Medium Blue', '285', '#0072ce'],
        ['Metallic Gold', '871 C', '#84754e'],
        ['Metallic Silver', '877 C', '#8d9092']
      ]
      embroidery_colors.each do |color|
        add_pms_color(
          supplier,
          embroidery_imprint,
          color[0],
          color[1],
          color[2]
        )
      end
    end

    desc 'Fix Bullet PMS Colors'
    task bullet: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '100383').first
      return if supplier.nil?

      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      color_blast_imprint = Spree::ImprintMethod.where(name: 'Color Blast').first_or_create
      label_imprint = Spree::ImprintMethod.where(name: 'Label').first_or_create
      transfer_imprint = Spree::ImprintMethod.where(name: 'Transfer').first_or_create

      add_these_colors = [
        ['Black', '426', '#25282B'],
        ['White', '000', '#FFFFFF'],
        ['Yellow', '012 C', '#ffd700'],
        ['Orange', '021 C', '#fe5000'],
        ['Red', '485 C', '#da291c'],
        ['Purple', '266 C', '#753bbd'],
        ['Burgundy', '202 C', '#862633'],
        ['Green', '347 C', '#009a44'],
        ['Royal Blue', '293 C', '#003da5'],
        ['Brown', '478 C', '#703f2a'],
        ['Light Gray', '428 C', '#703f2a'],
        ['Metallic Gold', '871 C', '#84754e'],
        ['Metallic Silver', '877 C', '#8d9092']
      ]
      add_these_colors.each do |color|
        screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
        color_blast_imprint = Spree::ImprintMethod.where(name: 'Color Blast').first_or_create
        label_imprint = Spree::ImprintMethod.where(name: 'Label').first_or_create
        transfer_imprint = Spree::ImprintMethod.where(name: 'Transfer').first_or_create

        add_pms_color(
          supplier,
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          color_blast_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          label_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          transfer_imprint,
          color[0],
          color[1],
          color[2]
        )
      end
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
        ['Orange', '021 C', '#fe5000'],
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

    desc 'Fix Leeds'
    task leeds: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '100306').first
      return if supplier.nil?

      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      transfer_imprint = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
      pad_print_imprint = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create

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
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          transfer_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          pad_print_imprint,
          color[0],
          color[1],
          color[2]
        )
      end
    end

    desc 'Fix Crown'
    task crown: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '101684').first
      return if supplier.nil?

      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      color_label_imprint = Spree::ImprintMethod.where(name: 'Color Label').first_or_create

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
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          color_label_imprint,
          color[0],
          color[1],
          color[2]
        )
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

    desc 'Fix Gemline'
    task gemline: :environment do
      supplier = Spree::Supplier.where(dc_acct_num: '100257').first_or_create

      screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      logomatic_imprint = Spree::ImprintMethod.where(name: 'Logomatic').first_or_create
      embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
      gemphoto_imprint = Spree::ImprintMethod.where(name: 'Gemphoto').first_or_create

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
          screen_print_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          logomatic_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          embroidery_imprint,
          color[0],
          color[1],
          color[2]
        )
        add_pms_color(
          supplier,
          gemphoto_imprint,
          color[0],
          color[1],
          color[2]
        )
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
