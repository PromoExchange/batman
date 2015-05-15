Deface::Override.new(
  virtual_path: 'spree/layouts/spree_application',
  insert_after: 'div.container',
  name:         'registration_future',
  text:         "<%= render partial: 'spree/shared/footer' %>"
)
