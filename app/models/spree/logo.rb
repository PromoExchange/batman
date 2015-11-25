class Spree::Logo < Spree::Base
  belongs_to :user
  validates :user_id, presence: true

  has_attached_file :logo_file,
    styles: {
      thumb: '100x100>',
      medium: '300x300>'
    },
    path: '/logo_file/:id/:style/:basename.:extension',
    default_style: 'thumb'

  validates_attachment_content_type :logo_file,
    content_type: %w(application/illustrator application/pdf image/x-eps image/vnd.adobe.photoshop)

  validates_attachment :logo_file, presence: true

  def artwork
    if logo_file_file_name.include?('.pdf')
      "artwork/pdf.png"
    elsif logo_file_file_name.include?('.ai')
      "artwork/ai.png"
    elsif logo_file_file_name.include?('.eps')
      "artwork/eps.jpg"
    else logo_file_file_name.include?('.psd')
      "artwork/psd.jpg"
    end
  end
end
