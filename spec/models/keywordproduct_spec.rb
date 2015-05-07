require 'rails_helper'

RSpec.describe KeywordProduct, type: :model do
  it 'should not create Keyword with a null word' do
    # setup
    k = KeywordProduct.new
    # exercise
    # verify
    expect(k.save).to eq false
    # teardown
  end

  it 'should create Keyword with a valid values' do
    # setup
    k = KeywordProduct.create( keyword_id: 1 , product_id: 1)
    # exercise
    # verify
    expect(k.save).to eq true
    # teardown
  end


  it 'should belong to a product' do
    # setup
    t = KeywordProduct.reflect_on_association(:product)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should belong to a keyword' do
    # setup
    t = KeywordProduct.reflect_on_association(:keyword)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end
end
