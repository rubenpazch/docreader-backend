require 'rails_helper'

RSpec.describe Product, type: :model do
  it { should have_many(:product_aliases).dependent(:destroy) }
  it { should have_many(:prices).dependent(:destroy) }
  it { should have_many(:brands).through(:prices) }
  it { should have_many(:qualities).through(:prices) }

  describe 'reglas de negocio' do
    it 'asigna public_uuid al crear' do
      product = create(:product)

      expect(product.public_uuid).to match(/\A[0-9a-f\-]{36}\z/)
    end

    it 'puede tener muchos alias' do
      product = create(:product)
      create(:product_alias, product: product)
      create(:product_alias, product: product)
      expect(product.product_aliases.count).to eq(2)
    end
  end
end
