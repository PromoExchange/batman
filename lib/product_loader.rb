module ProductLoader
  class FileNotFound < StandardError; end

  def self.load_products(file)
    # If file exists within application it takes precendence.
    if File.exist?(File.join(Rails.root, 'db', 'products', "#{file}.rb"))
      path = File.expand_path(File.join(Rails.root, 'db', 'products', "#{file}.rb"))
    else
      fail FileNotFound "File #{file} does not exist"
    end

    require path
    puts "Loaded #{file.titleize} products"
  end
end
