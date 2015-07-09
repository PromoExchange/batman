Spree::Api::ApiHelpers.module_eval do
  class_variable_set(:@@message_attributes,
    [
      :id,
      :owner_id,
      :from_id,
      :to_id,
      :status,
      :subject,
      :body,
      :created_at
    ])
  mattr_reader :message_attributes

  class_variable_set(:@@auction_attributes,
    [
      :id,
      :product_id,
      :name,
      :buyer_id,
      :lowest_bid,
      :quantity,
      :image_uri,
      :started,
      :ended,
      :status
    ])
  mattr_reader :auction_attributes

  class_variable_set(:@@bid_attributes,
    [
      :id,
      :auction_id,
      :seller_id,
      :email,
      :bid,
      :order_id,
      :prebid_id
    ])
  mattr_reader :bid_attributes

  class_variable_set(:@@prebid_attributes,
    [
      :id,
      :seller_id,
      :description
    ])
  mattr_reader :prebid_attributes

  class_variable_set(:@@favorite_attributes,
    [
      :id,
      :buyer_id,
      :product_id
    ])
  mattr_reader :favorite_attributes
end
