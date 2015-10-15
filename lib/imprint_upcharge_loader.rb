require 'csv'

module ImprintUpchargeLoader
  def self.load(file)
    load_count = 0
    error_count = 0

    load_name = File.join(Rails.root, "db/upcharge_data/#{file}")

    setup_type = Spree::UpchargeType.where(name: 'setup').first.id
    run_type = Spree::UpchargeType.where(name: 'run').first.id

    CSV.foreach(load_name, headers: true, header_converters: :symbol) do |row|
      hashed = row.to_hash

      is_setup = (hashed[:charge_type] == 'SETUP')

      imprint = Spree::ImprintMethod.where(slug: hashed[:imprint_slug]).first

      if imprint.nil?
        error_count += 1
        next
      end

      attrs = {
        upcharge_type_id: (is_setup ? setup_type : run_type),
        related_type: 'Spree::ImprintMethod'
      }
      attrs[:related_id] = imprint.id
      attrs[:price_code] = hashed[:price_code]

      if is_setup
        attrs[:value] = hashed[:price1]
        Spree::Upcharge.create(attrs)
        load_count += 1
      else
        (1..5).each do |i|
          range_key = "range#{i}".to_sym
          price_key = "price#{i}".to_sym

          next if hashed[range_key] == '0'

          attrs[:range] = hashed[range_key]
          attrs[:value] = hashed[price_key]
          attrs[:position] = i

          Spree::Upcharge.create(attrs)
          load_count += 1
        end
      end
    end
    puts "Loaded imprint upcharges:[#{load_name}]"
    puts "#{load_count} loaded, #{error_count} errors "
  end
end
