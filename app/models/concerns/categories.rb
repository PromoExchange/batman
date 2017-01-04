module Categories
  def categories_taxonomy
    Spree::Taxonomy.find_by(name: 'Categories')
  end

  def generic_taxon
    Spree::Taxon.find_by(taxonomy: categories_taxonomy, name: 'Generic')
  end

  def categories_taxons
    Spree::Taxon.where(taxonomy: categories_taxonomy).where.not(id: generic_taxon.id)
  end

  def quality_taxonomy
    Spree::Taxonomy.find_by(name: 'Categories')
  end
end
