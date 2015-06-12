Deface::Override.new(
  virtual_path:  'spree/products/show',
  name:          'add_request_more',
  insert_before: "[data-hook='product_properties']",
  partial:       'spree/product/request_info'
)
