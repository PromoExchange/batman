Deface::Override.new(
  virtual_path:  'spree/shared/_products',
  name:          'request_product',
  insert_before: "erb[silent]:contains('num_pages')",
  partial:       'spree/product/request_product'
)
