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

  it 'should save with a valid quote, with_shipping' do
    quote = FactoryGirl.build(:quote, :with_shipping_options)
    expect(quote.save).to be_truthy
  end

  it 'should save with a valid quote, with_shipping, with_workbook' do
    quote = FactoryGirl.build(:quote, :with_shipping_options, :with_workbook)
    expect(quote.save).to be_truthy
  end

  it 'should save with a valid quote, with_workbook' do
    quote = FactoryGirl.build(:quote, :with_workbook)
    expect(quote.save).to be_truthy
  end

  it 'should save with a value quote' do
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

  it 'should delete shipping_options' do
    quote_with_shipping = FactoryGirl.create(:quote, :with_shipping_options)
    expect { quote_with_shipping.destroy }.to change { Spree::ShippingOption.count }.by(-5)
  end

  it 'should delete shipping_options' do
    quote_with_shipping = FactoryGirl.create(:quote, :with_shipping_options)
    expect { quote_with_shipping.destroy }.to change { Spree::ShippingOption.count }.by(-5)
  end

  it 'should have a value in fields' do
    quote_with_workbook = FactoryGirl.create(:quote, :with_workbook)
    expect(quote_with_workbook.fields['one']).to eq 1
    expect(quote_with_workbook.fields['two']).to eq 2
  end

  it 'should have a value in fields' do
    quote = FactoryGirl.create(:quote)
    expect(quote.fields).to be_truthy
  end

  it 'should have a value in messages' do
    quote = FactoryGirl.create(:quote)
    expect(quote.messages).to be_truthy
  end

  it 'should save and restore values in fields' do
    quote = FactoryGirl.create(:quote)
    quote.fields['two'] = 2
    quote.fields['three'] = 3
    quote.save!
    quote2 = Spree::Quote.find(quote.id)
    expect(quote2.fields['two']).to eq 2
    expect(quote2.fields['three']).to eq 3
  end

  it 'should save and restore values in messages' do
    quote = FactoryGirl.create(:quote)
    5.times { quote.log('A new message') }
    quote.save!
    quote2 = Spree::Quote.find(quote.id)
    expect(quote2.messages.count).to eq 5
  end

  xit 'should have a total price of 100.0' do
    quote = FactoryGirl.build(:quote)
    expect(quote.total_price).to eq 100.00
  end
end
