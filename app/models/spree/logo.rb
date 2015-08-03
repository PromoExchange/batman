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
    content_type: %w(image/jpeg image/jpg image/png image/gif)

  validates_attachment :logo_file, presence: true
end
