Deface::Override.new(
  virtual_path:  'spree/products/index',
  name:          'side_bar_replace',
  replace:       "[data-hook='homepage_sidebar_navigation']",
  partial:       'spree/product/sidebar'
)
