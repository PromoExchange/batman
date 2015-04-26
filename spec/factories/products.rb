FactoryGirl.define do
  factory :product do
    name 'name'
    description 'description'
    includes 'includes'
    features 'features'
    packsize 1
    packweight 'packweight'
    unit_measure 'unit_measure'
    leadtime 'leadtime'
    rushtime 'rushtime'
    info 'MyString'
  end
end
