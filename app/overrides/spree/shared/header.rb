# remove spree logo
Deface::Override.new(
  virtual_path: 'spree/shared/_header',
  name:         'header_nav_bar_remove_logo',
  remove:       'figure#logo'
)
