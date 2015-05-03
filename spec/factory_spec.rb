# spec/factories_spec.rb
require 'rails_helper'

FactoryGirl.factories.map(&:name).each do |factory_name|
  describe "The #{factory_name} factory" do
    it 'is valid' do
      f = build(factory_name)
      expect(f).to be_valid
     end
  end
end
