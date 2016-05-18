class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :current_company_store

  def current_company_store
    return unless session[:company_store_id]
    @current_company_store ||= Spree::CompanyStore.find(session[:company_store_id])
  end

  def ping
    render json: { ping: 'pong' }
  end

  def after_sign_in_path_for(_resource)
    return root_path if session[:previous_urls].nil?
    @url = session[:previous_urls].reverse.first
    return @url unless @url.nil?
    root_path
  end
end
