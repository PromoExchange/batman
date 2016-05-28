Spree::FrontendHelper.class_eval do
  def breadcrumbs(taxon, separator = '&nbsp;')
    return '' if current_page?('/') || taxon.nil?

    separator = raw(separator)
    crumbs = [
      content_tag(
        :li,
        content_tag(
          :span,
          link_to(
            content_tag(:span, Spree.t(:home), itemprop: 'name'),
            spree.root_path,
            itemprop: 'url'
          ) + separator,
          itemprop: 'item'
        ),
        itemscope: 'itemscope',
        itemtype: 'https://schema.org/ListItem',
        itemprop: 'itemListElement'
      )
    ]

    if taxon
      crumbs << content_tag(:li, content_tag(:span, link_to(content_tag(:span, Spree.t(:products), itemprop: 'name'), '/t/categories', itemprop: 'url') + separator, itemprop: 'item'), itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement')
      crumbs << taxon.ancestors.collect { |ancestor| content_tag(:li, content_tag(:span, link_to(content_tag(:span, ancestor.name, itemprop: 'name'), seo_url(ancestor), itemprop: 'url') + separator, itemprop: 'item'), itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement') unless ancestor.name == 'Categories' } unless taxon.ancestors.empty?
      crumbs << content_tag(:li, content_tag(:span, link_to(content_tag(:span, taxon.name, itemprop: 'name'), seo_url(taxon), itemprop: 'url'), itemprop: 'item'), class: 'active', itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement') unless taxon.name == 'Categories'
    else
      crumbs << content_tag(:li, content_tag(:span, Spree.t(:products), itemprop: 'item'), class: 'active', itemscope: 'itemscope', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement')
    end

    crumb_list = content_tag(:ol, raw(crumbs.flatten.map { |li| li.mb_chars if li.present? }.join), class: 'breadcrumb', itemscope: 'itemscope', itemtype: 'https://schema.org/BreadcrumbList')
    content_tag(:nav, crumb_list, id: 'breadcrumbs', class: 'col-md-12')
  end
end
