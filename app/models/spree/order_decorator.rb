Spree::Order.class_eval do
  belongs_to :auction
  # TODO: Removed because sample data will not load
  # validates :auction_id, presence: true
end
