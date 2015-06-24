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
end
