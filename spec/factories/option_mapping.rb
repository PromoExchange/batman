FactoryGirl.define do
  factory :option_mapping, class: 'Spree::OptionMapping' do
    dc_acct_num '12345'
    dc_name 'bubbles'
    px_name 'cherios'
    do_not_save false
  end
end
