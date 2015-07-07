# Add product volume pricing tables
Deface::Override.new(
  virtual_path:  'spree/products/_cart_form',
  name:          'auction_button',
  insert_after:  "[data-hook='inside_product_cart_form']",
  text:          "<%= link_to Spree.t(:new_auction), main_app.new_auction_path(product_id: @product.id) , class: 'btn btn-default' %>"
)

Deface::Override.new(
  virtual_path:  'spree/products/_cart_form',
  name:          'volume_pricing_grid',
  replace:       "[data-hook='product_price']",
  text:          "<%= render partial: 'spree/products/volume_pricing', locals: { product: @product } %>"
)
