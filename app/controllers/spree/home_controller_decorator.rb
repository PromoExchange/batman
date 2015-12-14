Spree::HomeController.class_eval do

  def index
    @searcher = build_searcher(params.merge(include_images: true))
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)
    @blog_entries = Spree::BlogEntry.visible.order('created_at DESC').limit(5)
  end
  
  def send_request
    email = params[:request][:email]
    unless email.present? && (email =~ Devise.email_regexp)
      @msg = '<div class="alert alert-error">Email is not valid!</div>'
    else
      Resque.enqueue(SendRequestToLearn, email)
      @msg = '<div class="alert alert-success">Request sent successfully.</div>'
    end
  end
end
