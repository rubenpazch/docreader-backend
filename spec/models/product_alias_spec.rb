require 'rails_helper'


RSpec.describe ProductAlias, type: :model do
  subject { create(:product_alias) }
  it { should belong_to(:product) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  describe '.where(name: ...)' do
    let!(:product) { create(:product, name: 'Cuaderno A4', normalized_name: 'cuaderno a4') }
    let!(:alias1) { create(:product_alias, name: 'cuaderno a4', product: product) }
    let!(:alias2) { create(:product_alias, name: 'block a4', product: product) }

    it 'encuentra productos por alias en lote' do
      names = ['cuaderno a4', 'block a4']
      results = ProductAlias.where(name: names)
      expect(results.map(&:product)).to all(eq(product))
    end
  end

  describe 'reglas de negocio' do
    it 'asigna public_uuid al crear' do
      product_alias = create(:product_alias)

      expect(product_alias.public_uuid).to match(/\A[0-9a-f\-]{36}\z/)
    end

    it 'no permite alias duplicados' do
      product = create(:product)
      create(:product_alias, name: 'lapiz', product: product)
      expect(build(:product_alias, name: 'lapiz', product: product)).not_to be_valid
    end

    it 'permite varios alias para un producto' do
      product = create(:product)
      expect {
        create(:product_alias, name: 'borrador', product: product)
        create(:product_alias, name: 'goma de borrar', product: product)
      }.to change { product.product_aliases.count }.by(2)
    end
  end
end
