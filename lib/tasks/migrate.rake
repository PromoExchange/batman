namespace :migrate do
  desc 'Products to new category'
  task product_category: :environment do
    raise 'This is a run once only task' unless Spree::Taxonomy.where(name: 'Colors').present?

    # Clean up colors
    color_taxonomy = Spree::Taxonomy.where(name: 'Colors').first
    Spree::Taxon.where(taxonomy: color_taxonomy).destroy_all
    Spree::Taxonomy.where(name: 'Colors').destroy_all

    # Convert products to category
    Spree::CompanyStore.all.each do |cs|
      store_taxon = cs.store_taxon
      Spree::Product.where(supplier_id: cs.supplier_id).each do |product|
        Spree::Classification.where(
          product: product,
          taxon: store_taxon
        ).first_or_create
      end
    end

    # Convert Wearable to new Wearables
    categories_taxonomy = Spree::Taxon.where(name: 'Categories').first
    new_apparel_taxon = Spree::Taxon.where(
      name: 'Apparel',
      taxonomy: categories_taxonomy
    ).first

    old_apparel_taxon = Spree::Taxon.where(dc_category_guid: '7F4C59A7-6226-11D4-8976-00105A7027AA')
    Spree::Classification.where(taxon: old_apparel_taxon).each do |old_apparel_product|
      Spree::Classification.where(
        product: old_apparel_product.product,
        taxon: new_apparel_taxon
      ).first_or_create
    end
  end
end
