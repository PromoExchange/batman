# Add product volume pricing tables
Deface::Override.new(
  virtual_path:  'spree/products/_cart_form',
  name:          'volume_pricing',
  insert_before: "[data-hook='product_price']",
  text:          "<%= render partial: 'spree/products/volume_pricing', locals: { product: @product } %>"
)

# Add volume pricing variables to view for use by JS
Deface::Override.new(
  virtual_path:  'spree/products/show',
  name:          'volume_pricing_variables',
  insert_before: "[data-hook='product_show']"
) do
  <<-CODE.chomp
    <script>
      var allPrices = <%= @product.all_prices %>;
      var lowestDiscountedVolumePrice = <%= @product.lowest_discounted_volume_price %>;
    </script>
  CODE
end
