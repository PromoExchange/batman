# Add product volume pricing tables
Deface::Override.new(
  virtual_path:  'spree/products/_cart_form',
  name:          'volume_pricing_grid',
  replace:       "[data-hook='product_price']",
  text:          "<%= render partial: 'spree/products/volume_pricing', locals: { product: @product } %>"
)
