require './lib/product_loader'

namespace :product do
  namespace :load do
    desc 'Gemline Load'
    task gemline: :environment do
      supplier = 'gemline'
      ProductLoader.load('products', supplier)
      ProductLoader.load('upcharges', supplier)
    end

    desc 'Crown Load'
    task crown: :environment do
      supplier = 'crown'
      ProductLoader.load('products', supplier)
      ProductLoader.load('upcharges', supplier)
    end

    desc 'Fields Load'
    task fields: :environment do
      supplier = 'fields'
      ProductLoader.load('products', supplier)
      ProductLoader.load('upcharges', supplier)
    end

    desc 'Fields Load'
    task high_caliber: :environment do
      supplier = 'high_caliber'
      ProductLoader.load('products', supplier)
      ProductLoader.load('upcharges', supplier)
    end

    desc 'Leeds Load'
    task leeds: :environment do
      supplier = 'leeds'
      ProductLoader.load('products', supplier)
    end

    desc 'logomark Load'
    task logomark: :environment do
      supplier = 'logomark'
      ProductLoader.load('products', supplier)
      ProductLoader.load('upcharges', supplier)
    end

    desc 'norwood Load'
    task norwood: :environment do
      supplier = 'norwood'
      ProductLoader.load('products', supplier)
      ProductLoader.load('upcharges', supplier)
    end

    desc 'primeline Load'
    task primeline: :environment do
      supplier = 'primeline'
      ProductLoader.load('products', supplier)
      ProductLoader.load('upcharges', supplier)
    end

    desc 'sweda Load'
    task sweda: :environment do
      supplier = 'sweda'
      ProductLoader.load('products', supplier)
    end

    desc 'starline Load'
    task starline: :environment do
      supplier = 'starline'
      ProductLoader.load('products', supplier)
    end

    desc 'vitronic Load'
    task vitronic: :environment do
      supplier = 'vitronic'
      ProductLoader.load('products', supplier)
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
