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
    file_name = File.join(Rails.root, "db/product_data/#{file}")
    CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
      hashed = row.to_hash
      pms = Spree::PmsColor.where(name: hashed[:slug]).first
      Spree::PmsColorsSupplier.create(
        supplier_id: supplier_id,
        pms_color_id: pms.id,
        display_name: hashed[:display_name])
    end
  end
end
