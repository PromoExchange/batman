class MediaReference < ActiveRecord::Base
  validates :reference, presence: true
  validates_inclusion_of :location, in: %w( website catalog )
end
