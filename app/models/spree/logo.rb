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

  LOGO_FILE_NAME = { "pdf": "artwork/pdf.png", "ai": "artwork/ai.png", "eps": "artwork/eps.jpg",  "psd": "artwork/psd.jpg"}

  def artwork
    extension = logo_file_file_name.split(".")[1].to_sym
    "/assets/#{Spree::Logo::LOGO_FILE_NAME[extension]}"
  end
end
