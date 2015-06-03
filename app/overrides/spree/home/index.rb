# Remove products sidebar from homepage
Deface::Override.new(
  virtual_path: 'spree/home/index',
  name:         'home_index_remove_sidebar',
  remove:       "[data-hook='homepage_sidebar_navigation']"
)

# Replace products main view from homepage
Deface::Override.new(
  virtual_path: 'spree/home/index',
  name:         'home_index_remove_products',
  replace:       "[data-hook='homepage_products']",
  partial:      'spree/home/home_content'
)
