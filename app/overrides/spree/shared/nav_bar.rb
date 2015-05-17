# Add login
Deface::Override.new(
  virtual_path:  'spree/shared/_nav_bar',
  name:          'nav_bar_insert_login',
  insert_before: '#search-bar[data-hook]',
  partial:       'spree/shared/login_bar'
)

# Remove search
Deface::Override.new(
  virtual_path: 'spree/shared/_nav_bar',
  name:         'nav_bar_remove_search',
  remove:       '#search-bar[data-hook]'
)
