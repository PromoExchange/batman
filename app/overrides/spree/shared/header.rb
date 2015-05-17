Deface::Override.new(
  virtual_path: 'spree/shared/_header',
  name:         'header',
  replace:      'div#spree-header',
  partial:      'spree/shared/px_header'
)
