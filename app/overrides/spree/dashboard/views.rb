Deface::Override.new(
  virtual_path: 'spree/users/show',
  name:         'remove_my_account',
  remove:       "[data-hook='account_my_orders']"
)
