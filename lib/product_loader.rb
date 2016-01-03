module ProductLoader
  class FileNotFound < StandardError; end

  def self.load(folder, file)
    # If file exists within application it takes precendence.
    file = File.join(Rails.root, 'db', folder, "#{file}.rb")
    if File.exist?(file)
      path = File.expand_path(file)
    else
      fail FileNotFound "File #{file} does not exist"
    end
    require path
    puts "Loaded #{folder}/#{file}"
  end

  def self.pms_load(file, supplier_id)
    imprint_methods = Spree::ImprintMethod.pluck(:name, :id)
    imprint_methods.push(['all', nil])
    file_name = File.join(Rails.root, "db/product_data/#{file}")
    CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
      hashed = row.to_hash
      pms = Spree::PmsColor.where(name: hashed[:slug]).first
      if pms.nil?
        puts "Warning: Unable to locate #{hashed[:slug]} in pms master list"
      else
        imprint = imprint_methods.select { |name, _id| name == hashed[:imprint_method] }
        Spree::PmsColorsSupplier.create(
          supplier_id: supplier_id,
          pms_color_id: pms.id,
          display_name: hashed[:display_name],
          imprint_method_id: imprint[0][1]
        )
      end
    end
  end

  def self.main_color_map_load(file)
    main_color_map = {}
    file_name = File.join(Rails.root, file)
    CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
      hashed = row.to_hash

      main_color = hashed[:main_color]
      px_colors = []

      (1..3).each do |n|
        name = "px_color#{n}"
        px_colors << hashed[name.to_sym] if hashed[name.to_sym]
      end

      main_color_map[main_color.to_sym] = px_colors
    end
    main_color_map
  end

  def self.add_charge(product, imprint_method, upcharge_type, value, range, price_code, position)
    if range.blank?
      upcharge = Spree::UpchargeProduct.where(
        product: product,
        imprint_method: imprint_method,
        upcharge_type: upcharge_type
      ).first_or_create
    else
      upcharge = Spree::UpchargeProduct.where(
        product: product,
        imprint_method: imprint_method,
        upcharge_type: upcharge_type,
        range: range
      ).first_or_create
    end
    upcharge.update_attributes(
      value: value,
      range: range,
      price_code: price_code,
      position: position
    )
  end
end
