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

  class_variable_set(:@@address_attributes,
    [
      :id,
      :company,
      :firstname,
      :lastname,
      :address1,
      :address2,
      :city,
      :state_name,
      :country,
      :state_id,
      :country_id,
      :zipcode,
      :phone,
      :is_bill,
      :is_ship
    ])
  mattr_reader :address_attributes

  class_variable_set(:@@auction_attributes,
    [
      :id,
      :product_id,
      :name,
      :buyer_id,
      :buyer_email,
      :buyer_company,
      :quantity,
      :image_uri,
      :started,
      :ended,
      :state,
      :payment_claimed,
      :reference,
      :product_unit_price,
      :payment_method,
      :proof_feedback,
      :shipping_agent,
      :tracking_number
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
      :state,
      :manage_workflow
    ])
  mattr_reader :bid_attributes

  class_variable_set(:@@user_attributes,
    [
      :id,
      :email
    ])
  mattr_reader :user_attributes

  class_variable_set(:@@review_attributes,
    [
      :id,
      :rating
    ])
  mattr_reader :review_attributes

  class_variable_set(:@@prebid_attributes,
    [
      :id,
      :seller_id,
      :description
    ])
  mattr_reader :prebid_attributes

  class_variable_set(:@@product_request_attributes,
    [
      :id,
      :title
    ])
  mattr_reader :product_request_attributes

  class_variable_set(:@@request_idea_attributes,
    [
      :id,
      :sku,
      :image_uri,
      :state,
      :auction_id,
      :product_variant
    ])
  mattr_reader :request_idea_attributes

  class_variable_set(:@@product_attributes,
    [
      :id,
      :name,
      :slug
    ])
  mattr_reader :product_attributes
end
