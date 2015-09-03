FactoryGirl.define do
  factory :auctions_user, class: Spree::AuctionsUser do
    user
    auction
  end
end
