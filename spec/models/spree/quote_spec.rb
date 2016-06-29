require 'rails_helper'

RSpec.describe Spree::Quote, type: :model do
  it 'should not save with a nil main_color' do
    quote = FactoryGirl.build(:quote, main_color: nil)
    expect(quote.save).to be_falsey
  end

  it 'should not save with a nil shipping_address' do
    quote = FactoryGirl.build(:quote, shipping_address: nil)
    expect(quote.save).to be_falsey
  end

  it 'should not save with a nil imprint_method' do
    quote = FactoryGirl.build(:quote, imprint_method: nil)
    expect(quote.save).to be_falsey
  end

  it 'should not save with a nil quantity' do
    quote = FactoryGirl.build(:quote, quantity: nil)
    expect(quote.save).to be_falsey
  end

  it 'should not save with a less than min quantity' do
    quote = FactoryGirl.build(:quote, quantity: 1)
    expect(quote.save).to be_falsey
  end

  it 'should save with a valid quote' do
    quote = FactoryGirl.build(:quote)
    expect(quote.save).to be_truthy
  end

  it 'should belong to an main_color' do
    t = Spree::Quote.reflect_on_association(:main_color)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to an product' do
    t = Spree::Quote.reflect_on_association(:product)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to an shipping_address' do
    t = Spree::Quote.reflect_on_association(:shipping_address)
    expect(t.macro).to eq :belongs_to
  end

  it 'should belong to an imprint_method' do
    t = Spree::Quote.reflect_on_association(:imprint_method)
    expect(t.macro).to eq :belongs_to
  end

  it 'should have many shipping_options' do
    t = Spree::Quote.reflect_on_association(:shipping_options)
    expect(t.macro).to eq :has_many
  end

  it 'should have many pms_colors' do
    t = Spree::Quote.reflect_on_association(:pms_colors)
    expect(t.macro).to eq :has_many
  end

  it 'should delete shipping_options' do
    quote_with_shipping = FactoryGirl.create(:quote)
    expect { quote_with_shipping.destroy }.to change { Spree::ShippingOption.count }.by(-5)
  end

  it 'should delete shipping_options' do
    quote_with_shipping = FactoryGirl.create(:quote)
    expect { quote_with_shipping.destroy }.to change { Spree::ShippingOption.count }.by(-5)
  end

  it 'should add a log message' do
    quote = FactoryGirl.build(:quote)
    5.times { quote.log('Test message') }
    expect(quote.messages.count).to eq 5
  end

  it 'should save and restore messages' do
    quote = FactoryGirl.build(:quote)
    5.times { quote.log('Test message') }
    quote.save
    quote2 = Spree::Quote.find(quote.id)
    expect(quote2.messages.count).to eq 5
  end

  it 'should return num of colors' do
    quote = FactoryGirl.build(:quote)
    expect(quote.num_colors).to eq 2
  end

  it 'should generate a reference' do
    quote = FactoryGirl.create(:quote, reference: nil)
    quote2 = Spree::Quote.find(quote.id)
    expect(quote2.reference).not_to be_empty
  end
end
