Deface::Override.new(
  virtual_path:   'spree/products/show',
  name:           'supplier_sku',
  insert_after:   'h1.product-title',
  partial:        'spree/product/supplier_sku'
)
