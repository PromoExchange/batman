Spree::UserConfirmationsController.class_eval do
  protected

   def after_resending_confirmation_instructions_path_for(_resource_name)
     root_path
   end
end
