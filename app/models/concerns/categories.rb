module Categories
  def categories_taxonomy
    Spree::Taxonomy.find_by(name: 'Categories')
  end

  def categories_taxons
    Spree::Taxon.where(taxonomy: categories_taxonomy).where.not(id: generic_taxon.id)
  end

  def generic_taxon
    Spree::Taxon.find_by(taxonomy: categories_taxonomy, name: 'Generic')
  end

  def quality_taxonomy
    Spree::Taxonomy.find_by(name: 'Quality')
  end

  def quality_taxons
    Spree::Taxon.where(taxonomy: quality_taxonomy)
  end
end
