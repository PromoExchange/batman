Spree::StoreController.class_eval do
  def store_location
    session[:previous_urls] ||= []
    if session[:previous_urls].first != request.fullpath &&
        request.fullpath != '/user' &&
        request.fullpath != '/user/login' &&
        request.fullpath != '/' &&
        request.fullpath != '/user/logout'
      session[:previous_urls].prepend request.fullpath
      session[:previous_urls].pop if session[:previous_urls].count > 3
    end
  end
end
