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
end
