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
      :buyer_email,
      :quantity,
      :image_uri,
      :started,
      :ended,
      :status,
      :reference,
      :product_unit_price,
      :payment_method
    ])
  mattr_reader :auction_attributes

  class_variable_set(:@@bid_attributes,
    [
      :id,
      :auction_id,
      :seller_id,
      :email,
      :per_unit_bid,
      :order_id,
      :bid,
      :seller_fee,
      :prebid_id,
      :status
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
