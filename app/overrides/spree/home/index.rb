# Add carousel
Deface::Override.new(
  virtual_path:  'spree/home/index',
  name:          'home_index_add_carousel',
  insert_before: "[data-hook='homepage_sidebar_navigation']",
  partial:       'spree/home/carousel'
)

# Add buyer/seller info
Deface::Override.new(
  virtual_path:  'spree/home/index',
  name:          'home_index_add_user_info',
  insert_before: "[data-hook='homepage_sidebar_navigation']",
  partial:       'spree/home/user_info'
)

# Remove products sidebar from homepage
Deface::Override.new(
  virtual_path: 'spree/home/index',
  name:         'home_index_remove_sidebar',
  remove:       "[data-hook='homepage_sidebar_navigation']"
)

# Remove products main view from homepage
Deface::Override.new(
  virtual_path: 'spree/home/index',
  name:         'home_index_remove_products',
  remove:       "[data-hook='homepage_products']"
)
