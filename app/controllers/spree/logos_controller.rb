class Spree::LogosController < Spree::StoreController
  def create
    session[:return_to] ||= request.referer
    session[:return_to] = main_app.dashboards_path(tab: 'logo') if session[:return_to].include?('dashboards')
    @logo = Spree::Logo.new(logo_params)

    if @logo.save
      redirect_to session.delete(:return_to), flash: { notice: 'Logo uploaded sucessfully.' }
    else
      redirect_to main_app.dashboards_path(tab: 'logo'), flash: { error: 'Failed to upload logo.' }
    end
  end

  def destroy
    Spree::Logo.destroy(params[:id])
    redirect_to main_app.dashboards_path(tab: 'logo'), flash: { notice: 'Logo deleted sucessfully.' }
  end

  private

  def logo_params
    params.require(:logo).permit(:user_id, :logo_file)
  end
end
