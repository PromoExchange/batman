require './lib/product_loader'

def load_files(supplier)
  ProductLoader.load('products', supplier)
  ProductLoader.load('upcharges', supplier)
end

namespace :product do
  namespace :load do
    desc 'Gemline Load'
    task gemline: :environment do
      load_files('gemline')
    end

    desc 'Crown Load'
    task crown: :environment do
      load_files('crown')
    end

    desc 'Fields Load'
    task fields: :environment do
      load_files('fields')
    end

    desc 'High Caliber Load'
    task high_caliber: :environment do
      load_files('high_caliber')
    end

    desc 'Leeds Load'
    task leeds: :environment do
      ProductLoader.load('products', 'leeds')
    end

    desc 'Logomark Load'
    task logomark: :environment do
      load_files('logomark')
    end

    desc 'Norwood Load'
    task norwood: :environment do
      ProductLoader.load('products', 'norwood')
    end

    desc 'Primeline Load'
    task primeline: :environment do
      load_files('primeline')
    end

    desc 'Sweda Load'
    task sweda: :environment do
      ProductLoader.load('products', 'sweda')
    end

    desc 'Starline Load'
    task starline: :environment do
      load_files('starline')
    end

    desc 'Vitronic Load'
    task vitronic: :environment do
      load_files('vitronic')
    end

    desc 'Product Load'
    task all: [
      'environment',
      'product:load:gemline',
      'product:load:crown',
      'product:load:fields',
      'product:load:leeds',
      'product:load:logomark',
      'product:load:norwood',
      'product:load:primeline',
      'product:load:sweda',
      'product:load:starline',
      'product:load:vitronic'
    ]
  end
end
