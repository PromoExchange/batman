json.products @products do |product|
  json.id     product.id
  # json.supplier_id    product.supplier.id
  json.name   product.name
  json.description   product.description
  json.info   product.info
  json.features   product.features
  # json.artist_id album.artist ? album.artist.id : nil
end
