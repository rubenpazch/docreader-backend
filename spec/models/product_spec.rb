require 'rails_helper'

RSpec.describe Product, type: :model do
  it { should have_many(:product_aliases).dependent(:destroy) }

  describe 'reglas de negocio' do
    it 'puede tener muchos alias' do
      product = create(:product)
      create(:product_alias, product: product)
      create(:product_alias, product: product)
      expect(product.product_aliases.count).to eq(2)
    end
  end
end
