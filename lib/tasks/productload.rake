require './lib/product_loader'

namespace :product do
  desc 'Product Load'
  task load: :environment do
    %w(
      gemline
      crown
      fields
      high_caliber
      leeds
      logomark
      norwood
      primeline
      sweda
      starline
      vitronic
    ).each { |supplier| ProductLoader.load('products', supplier) }

    # TODO: Merge these into the main product load queue
    %w(
      gemline
      crown
      fields
      high_caliber
      logomark
      primeline
      starline
      vitronic
    ).each { |supplier| ProductLoader.load('upcharges', supplier) }
  end
end
