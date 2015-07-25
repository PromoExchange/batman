class AddAttachmentToLogoTable < ActiveRecord::Migration
  def change
    add_attachment :spree_logos, :logo
  end
end
