FactoryGirl.define do
  factory :logo, parent: :image, class: Spree::Logo do
    association :user, factory: :user
    attachment { File.new(Rails.root.join('spec', 'fixtures', 'batman.jpeg')) }
  end
end
