Deface::Override.new(
  virtual_path:     'spree/shared/_products',
  name:             'search_result_price',
  replace_contents: 'div.panel-footer',
  partial:          'spree/product/index_auction'
)
