RSpec.shared_context 'spree_shared' do
  let(:current_api_user) do
    user = Spree.user_class.new(
      email: 'spree@example.com',
      password: 'password'
    )
    user.generate_spree_api_key!
    user
  end
end
