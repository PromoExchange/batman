Spree::HomeController.class_eval do
  def index
    # Redirect to a company store if requested
    # If the URI is
    # 1. <xxx>.thepromoexchange.com AND xxx matches a slug, we have a store
    # 2. <xxx>.promox.co AND xxx matches a slug, we have a store
    host = URI(request.base_url).host
    @current_company_store = Spree::CompanyStore.where(slug: host.split('.')[0]).first
    if @current_company_store.nil? && ENV['COMPANYSTORE_ID'].present?
      @current_company_store = Spree::CompanyStore.where(slug: ENV['COMPANYSTORE_ID']).first
    end

    unless @current_company_store.nil?
      redirect_to "/company_store/#{@current_company_store.slug}"
    end

    # Continue to main site
    @searcher = build_searcher(params.merge(include_images: true))
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)
    @blog_entries = Spree::BlogEntry.visible.order('created_at DESC').limit(5)
  end

  def send_request
    email = params[:request][:email]
    if email.nil? || !(email =~ Devise.email_regexp)
      @msg = '<div class="alert alert-error">Email is not valid!</div>'
    else
      Resque.enqueue(SendRequestToLearn, email)
      @msg = '<div class="alert alert-success">Request sent successfully.</div>'
    end
  end
end
