Spree::HomeController.class_eval do
  def index
    @current_company_store = Spree::CompanyStore.where(host: URI(request.base_url).host).first
    if @current_company_store.nil? && ENV['COMPANYSTORE_ID'].present?
      @current_company_store = Spree::CompanyStore.where(slug: ENV['COMPANYSTORE_ID']).first
    end

    unless @current_company_store.nil?
      redirect_to "/company_store/#{@current_company_store.slug}"
    end

    session.delete(:company_store_id)

    # Continue to main site
    @searcher = build_searcher(params.merge(include_images: true))
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)
  end
end
