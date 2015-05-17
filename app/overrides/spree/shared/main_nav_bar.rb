# Add PX logo
Deface::Override.new(
  virtual_path:   'spree/shared/_main_nav_bar',
  name:           'main_nav_bar_add_px_logo',
  insert_before:  '#home-link[data-hook]',
  text:           '<figure id=\"logo\" class=\"col-md-4\" data-hook><%= logo %></figure>'
)

# Add search functionality
Deface::Override.new(
  virtual_path:  'spree/shared/_main_nav_bar',
  name:          'main_nav_bar_insert_search',
  insert_before: 'ul.navbar-right'
) do
  <<-CODE.chomp
  <ul class="nav navbar-nav">
    <li id="search-bar" data-hook>
      <%= render :partial => "spree/shared/search" %>
    </li>
  </ul>
  CODE
end

# Remove home link
Deface::Override.new(
  virtual_path: 'spree/shared/_main_nav_bar',
  name:         'main_nav_bar_remove_home_link',
  remove:       '#home-link[data-hook]'
)
