Spree::StoreController.class_eval do
  def store_location
    session[:previous_urls] ||= []
    return if session[:previous_urls].first == request.fullpath ||
        ['/user', '/user/login', '/', '/user/logout'].include?(request.fullpath)
    session[:previous_urls].prepend request.fullpath
    session[:previous_urls].pop if session[:previous_urls].count > 3
  end
end
