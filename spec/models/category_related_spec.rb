require 'rails_helper'

RSpec.describe CategoryRelated, type: :model do
  it 'should not create category_related with nulls' do
    # setup
    p = CategoryRelated.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create category_related with valid values' do
    # setup
    p = CategoryRelated.new
    p.category_id = 1
    p.related_id = 1

    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'should create category_related with valid related category' do
    # setup
    c = create(:category)
    cr = create(:category_related, category_id: c.id, related_id: c.id )

    # exercise
    # verify
    expect(cr.category.name).to eq "CATEGORY"
    # teardown
  end

  it 'should create category_related with valid 2 related categories' do
    DatabaseCleaner.clean
    # setup
    c = create(:category)
    c2 = create(:category, name: "CATEGORY2")
    cr = create(:category_related, category_id: c.id, related_id: c.id )
    cr2 = create(:category_related, category_id: c.id, related_id: c2.id )
    cr3 = create(:category_related, category_id: c2.id, related_id: c2.id )

    # exercise
    # verify
    crs = CategoryRelated.limit(3)
    Rails.logger.debug crs.inspect
    crc = crs[2]
    expect(crc.category.name).to eq "CATEGORY2"
    # teardown
  end

  it 'test category_related factory' do
    # setup
    c = build(:category_related)
    # exercise
    # verify
    expect(c.category_id).not_to eq(nil)
    expect(c.related_id).not_to eq(nil)
    # teardown
  end


end