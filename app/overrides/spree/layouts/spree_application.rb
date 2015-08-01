# Add footer
Deface::Override.new(
  virtual_path: 'spree/layouts/spree_application',
  name:         'footer',
  insert_after: 'div.container',
  partial:      'spree/shared/footer'
)

Deface::Override.new(
  virtual_path: 'spree/layouts/spree_application',
  name:         'google_fonts',
  insert_bottom: '[data-hook="inside_head"]',
  text: "<link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>"
)
