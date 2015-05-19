# Add login
Deface::Override.new(
  virtual_path:  'spree/shared/_nav_bar',
  name:          'nav_bar_insert_login',
  insert_before: '#search-bar[data-hook]',
  partial:       'spree/shared/login_bar'
)

# Add About Us page link
Deface::Override.new(
  virtual_path: 'spree/shared/_nav_bar',
  name:         'nav_bar_insert_about_us',
  insert_after: '#search-bar[data-hook]',
  text:         '<li><a href="/aboutus">About Us</a></li>'
)

# Remove search
Deface::Override.new(
  virtual_path: 'spree/shared/_nav_bar',
  name:         'nav_bar_remove_search',
  remove:       '#search-bar[data-hook]'
)
