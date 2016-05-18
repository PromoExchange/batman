namespace :companystore do
  desc 'Assign new company store data'
  task assign_data: :environment do
    [
      {
        slug: 'xactly',
        email: 'xactly_cs@thepromoexchange.com',
        host: 'xactly.promox.co'
      },
      {
        slug: 'hightail',
        email: 'hightail_cs@thepromoexchange.com',
        host: 'hightail.promox.co'
      },
      {
        slug: 'netmining',
        email: 'netmining_cs@thepromoexchange.com',
        host: 'netmining.promox.co'
      },
      {
        slug: 'anchorfree',
        email: 'anchorfree_cs@thepromoexchange.com',
        host: 'anchorfree.promox.co'
      }
    ].each do |assignment|
      company_store = Spree::CompanyStore.where(slug: assignment[:slug]).first
      fail "Failed to find company store #{assignment[:slug]}" if company_store.nil?

      user = Spree::User.where(email: assignment[:email]).first
      fail "Failed to find email#{assignment[:email]}" if user.nil?

      company_store.update_attributes(buyer: user, host: assignment[:host])
    end
  end
end
