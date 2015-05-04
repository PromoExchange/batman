json.products do |json|
  json.array!(@products) do |product|
    json.id product.id
    json.supplier_id product.supplier.id
    json.name product.name
    json.description product.description
    json.info product.info
    json.features product.features
  end
end
# json.products do |json|
#   json.array!(@products) do |pp, product|
#     pp.partial! 'products/product', product: product
#   end
# end
