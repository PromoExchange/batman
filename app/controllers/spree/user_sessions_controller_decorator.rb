Spree::UserSessionsController.class_eval do
  def after_sign_in_path_for(_resource)
    if spree_current_user.has_spree_role?('admin')
      admin_path
    else
      main_app.dashboards_path
    end
  end
end
