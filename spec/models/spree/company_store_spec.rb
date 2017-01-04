require 'rails_helper'

RSpec.describe Spree::CompanyStore, type: :model do
  describe 'factory' do
    it 'should build a valid company_store' do
      company_store = FactoryGirl.build(:company_store)
      expect(company_store.valid?).to be_truthy
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:buyer_id) }
    it { should validate_presence_of(:supplier_id) }
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:host) }
  end

  describe 'methods' do
    let(:company_store) { FactoryGirl.create(:company_store) }

    it 'should have a specific cache key' do
      expect(company_store.cache_key =~ /#{company_store.id}/).to be_truthy
      expect(company_store.cache_key =~ /^#{company_store.model_name.cache_key}/).to be_truthy
    end

    it 'should have a specific cache key for new' do
      company_store = FactoryGirl.build(:company_store)
      expect(company_store.cache_key =~ /new/).to be_truthy
      expect(company_store.cache_key =~ /^#{company_store.model_name.cache_key}/).to be_truthy
    end

    it 'should return a valid taxon for this CS' do
      expect(company_store.store_taxon.valid?).to be_truthy
      product_taxonomy = Spree::Taxonomy.where(name: 'Stores').first
      expect(company_store.store_taxon.taxonomy).to eq product_taxonomy
      expect(company_store.store_taxon.parent).to be_nil
    end
  end
end
