namespace :companystore do
  desc 'Assign new company store email'
  task assign_users: :environment do
    [
      {
        slug: 'xactly',
        email: 'xactly_cs@thepromoexchange.com'
      },
      {
        slug: 'hightail',
        email: 'hightail_cs@thepromoexchange.com'
      },
      {
        slug: 'netmining',
        email: 'netmining_cs@thepromoexchange.com'
      },
      {
        slug: 'anchorfree',
        email: 'anchorfree_cs@thepromoexchange.com'
      }
    ].each do |assignment|
      company_store = Spree::CompanyStore.where(slug: assignment[:slug]).first
      fail "Failed to find company store #{assignment[:slug]}" if company_store.nil?

      user = Spree::User.where(email: assignment[:email]).first
      fail "Failed to find email#{assignment[:email]}" if user.nil?

      company_store.update_attributes(buyer: user)
    end
  end
end
