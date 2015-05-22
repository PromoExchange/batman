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
    <div class="header-nav-elements">
      <a href="/buyer_how_it_works"><h2 class="header-nav-element">BUYERS</h2></a>
      <a href="/seller_how_it_works"><h2 class="header-nav-element">SELLERS</h2></a>
      <a href="/products"><h2 class="header-nav-element">PRODUCTS</h2></a>
      <a href="/faq"><h2 class="header-nav-element">FAQ</h2></a>
      <a href="/contact"><h2 class="header-nav-element">CONTACT US</h2></a>
    </div>
  </ul>
  CODE
end

# Remove home link
Deface::Override.new(
  virtual_path: 'spree/shared/_main_nav_bar',
  name:         'main_nav_bar_remove_home_link',
  remove:       '#home-link[data-hook]'
)
