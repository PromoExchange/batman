class Spree::Logo < Spree::Base
  belongs_to :user
  validates :user_id, presence: true

  has_attached_file :logo_file, path: '/logo_file/:id/:style/:basename.:extension'


  validates_attachment_content_type :logo_file,
    content_type: %w(application/illustrator application/pdf application/postscript image/vnd.adobe.photoshop)

  validates_attachment :logo_file, presence: true

  LOGO_FILE_NAME = { "pdf": "artwork/pdf.png", "ai": "artwork/ai.png", "eps": "artwork/eps.jpg",  "psd": "artwork/psd.jpg"}

  def artwork
    if logo_file_file_name.present?
      extension = logo_file_file_name.split(".").last.to_sym
      "/assets/#{Spree::Logo::LOGO_FILE_NAME[extension]}"
    end
  end
end
