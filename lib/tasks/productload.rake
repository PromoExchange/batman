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

    desc 'Gemline lite load'
    task gemline_lite: :environment do
      ProductLoader.load('lite', 'gemline')
    end

    desc 'Crown Load'
    task crown: :environment do
      load_files('crown')
    end

    desc 'Crown Lite Load'
    task crown_lite: :environment do
      ProductLoader.load('lite', 'crown')
    end

    desc 'Fields Load'
    task fields: :environment do
      load_files('fields')
    end

    desc 'Fields lite load'
    task fields_lite: :environment do
      ProductLoader.load('lite', 'fields')
    end

    desc 'High Caliber Load'
    task high_caliber: :environment do
      load_files('high_caliber')
    end

    desc 'High Caliber lite Load'
    task high_caliber_lite: :environment do
      ProductLoader.load('lite', 'high_caliber')
    end

    desc 'Leeds Load'
    task leeds: :environment do
      ProductLoader.load('products', 'leeds')
    end

    desc 'Leeds Lite Load'
    task leeds_lite: :environment do
      ProductLoader.load('lite', 'leeds')
    end

    desc 'Leeds Carton check'
    task leeds_carton_check: :environment do
      ProductLoader.load('lite', 'leeds_carton_check')
    end

    desc 'Logomark Load'
    task logomark: :environment do
      load_files('logomark')
    end

    desc 'Logomark Lite Load'
    task logomark_lite: :environment do
      ProductLoader.load('lite', 'logomark')
    end

    desc 'Norwood Load'
    task norwood: :environment do
      ProductLoader.load('products', 'norwood')
    end

    desc 'Norwood Load'
    task norwood_lite: :environment do
      ProductLoader.load('lite', 'norwood')
    end

    desc 'Primeline Load'
    task primeline: :environment do
      load_files('primeline')
    end

    desc 'Primeline Load'
    task primeline_lite: :environment do
      ProductLoader.load('lite', 'primeline')
    end

    desc 'Sweda Load'
    task sweda: :environment do
      ProductLoader.load('products', 'sweda')
    end

    desc 'Sweda Lite Load'
    task sweda_lite: :environment do
      ProductLoader.load('lite', 'sweda')
    end

    desc 'Starline Load'
    task starline: :environment do
      load_files('starline')
    end

    desc 'Starline Lite Load'
    task starline_lite: :environment do
      ProductLoader.load('lite', 'starline')
    end

    desc 'Jornik Load'
    task jornik: :environment do
      load_files('jornik')
    end

    desc 'Bullet Load'
    task bullet: :environment do
      load_files('bullet')
    end

    desc 'Bullet Lite Load'
    task bullet_lite: :environment do
      ProductLoader.load('lite', 'bullet')
    end

    desc 'Vitronic Load'
    task vitronic: :environment do
      load_files('vitronic')
    end

    desc 'Vitronic Lite Load'
    task vitronic_lite: :environment do
      ProductLoader.load('lite', 'vitronic')
    end

    desc 'Gildan Load'
    task gildan: :environment do
      ProductLoader.load('products', 'gildan')
    end

    desc 'Alternative Apparel Load'
    task alternative_apparel: :environment do
      ProductLoader.load('products', 'alternative_apparel')
    end

    desc 'Spector Load'
    task spector: :environment do
      load_files('spector')
    end

    desc 'Product Load'
    task work: [
      'environment',
      'product:load:vitronic',
      'product:load:gildan',
      'product:load:alternative_apparel',
      'product:load:spector'
    ]

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
      'product:load:vitronic',
      'product:load:gildan',
      'product:load:jornik',
      'product:load:bullet',
      'product:load:alternative_apparel'
    ]

    desc 'Product Lite Load'
    task lite: [
      'environment',
      'product:load:gemline_lite',
      'product:load:crown_lite',
      'product:load:fields_lite',
      'product:load:high_caliber_lite',
      'product:load:leeds_lite',
      'product:load:logomark_lite',
      'product:load:norwood_lite',
      'product:load:primeline_lite',
      'product:load:sweda_lite',
      'product:load:starline_lite',
      'product:load:bullet_lite',
      'product:load:vitronic_lite'
    ]
  end
end
