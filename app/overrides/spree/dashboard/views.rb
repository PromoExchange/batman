Deface::Override.new(
  virtual_path: 'spree/users/show',
  name:         'user_dashboard',
  replace:      "[data-hook='account_summary']",
  partial:      'spree/dashboard/index'
)

Deface::Override.new(
  virtual_path: 'spree/users/show',
  name:         'remove_my_account',
  remove:       "[data-hook='account_my_orders']"
)
