module ProductLoader
  class FileNotFound < StandardError; end

  def self.load(folder, file)
    # If file exists within application it takes precendence.
    if File.exist?(File.join(Rails.root, 'db', folder, "#{file}.rb"))
      path = File.expand_path(File.join(Rails.root, 'db', 'products', "#{file}.rb"))
    else
      fail FileNotFound "File #{file} does not exist"
    end

    require path
    puts "Loaded #{folder}/#{file} products"
  end
end
