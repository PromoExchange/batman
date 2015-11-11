namespace :dc do
  namespace :product do
    desc 'Reload All products in database'
    task reload: :environment do
      Spree::Product.all.each do |product|
        product.loading
        Resque.enqueue(
          ProductLoad,
          supplier_item_guid: product.supplier_item_guid
        )
      end
    end
  end

  namespace :category do
    desc 'Reload DC Categories'
    task reload: :environment do
      category_taxonomy = Spree::Taxonomy.where(name: 'Categories').first_or_create
      Spree::Taxon.where(taxonomy_id: category_taxonomy.id).destroy_all

      category_taxonomy = Spree::Taxonomy.where(name: 'Categories').first_or_create
      category_taxon = Spree::Taxon.where(
        name: 'Categories',
        parent_id: nil,
        taxonomy_id: category_taxonomy.id
      ).first_or_create

      tree = Spree::DcCategory.category_tree
      tree.each do |parent|
        puts "#{parent.name}"
        parent_taxon = Spree::Taxon.create(
          name: parent.name,
          dc_category_guid: parent.guid,
          parent_id: category_taxon.id,
          taxonomy_id: category_taxonomy.id
        )
        parent.children.each do |child|
          puts "--->#{child.name}"
          Spree::Taxon.create(
            name: child.name,
            dc_category_guid: child.guid,
            parent_id: parent_taxon.id,
            taxonomy_id: category_taxonomy.id
          )
        end
      end
    end
  end
end
