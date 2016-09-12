class Spree::Logo < Spree::Base
  LOGO_FILE_NAME = {
    pdf: 'artwork/pdf.png',
    ai: 'artwork/ai.png',
    eps: 'artwork/eps.jpg',
    psd: 'artwork/psd.jpg'
  }.freeze

  belongs_to :user
  has_many :purchase

  has_attached_file :logo_file, path: '/logo_file/:id/:style/:basename.:extension'

  validates_attachment :logo_file, presence: true
  validates_attachment_content_type :logo_file,
    content_type: %w(application/illustrator application/pdf application/postscript image/vnd.adobe.photoshop)
  validates :user_id, presence: true

  def artwork
    return unless logo_file_file_name.present?
    "/assets/#{Spree::Logo::LOGO_FILE_NAME[logo_file_file_name.split('.').last.to_sym]}"
  end
end
