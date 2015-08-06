class Spree::LogosController < Spree::StoreController
  def create
    @logo = Spree::Logo.new(logo_params)

    if @logo.save
      redirect_to main_app.dashboards_path, flash: { notice: 'Logo upload sucessfully.' }
    else
      redirect_to main_app.dashboards_path, flash: { error: 'Failed to upload logo.' }
    end
  end

  def destroy
    Spree::Logo.destroy(params[:id])
    redirect_to main_app.dashboards_path, flash: { notice: 'Logo deleted sucessfully.' }
  end

  private

  def logo_params
    params.require(:logo).permit(:user_id, :logo_file)
  end
end
