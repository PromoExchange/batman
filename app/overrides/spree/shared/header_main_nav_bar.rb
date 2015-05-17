# # Add PX logo
Deface::Override.new(
  virtual_path:   'spree/shared/_main_nav_bar',
  name:           'header_main_nav_bar_add_px_logo',
  insert_before:  '#home-link[data-hook]',
  text:           '<figure id=\"logo\" class=\"col-md-4\" data-hook><%= logo %></figure>'
)

# Remove home link
Deface::Override.new(
  virtual_path:   'spree/shared/_main_nav_bar',
  name:           'header_main_nav_bar_remove_home_link',
  remove:         '#home-link[data-hook]'
)
