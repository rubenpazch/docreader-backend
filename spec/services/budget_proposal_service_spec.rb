require 'rails_helper'

RSpec.describe BudgetProposalService, type: :service do
  describe '#call' do
    it 'construye propuestas economica, balanceada y premium' do
      product = create(:product, name: 'Cuaderno 100 hojas', normalized_name: 'cuaderno-100-hojas')
      brand_a = create(:brand, name: 'Marca A')
      brand_b = create(:brand, name: 'Marca B')
      brand_c = create(:brand, name: 'Marca C')
      quality = create(:quality, level: 'estandar')

      create(:price, product: product, brand: brand_a, quality: quality, value: 8.0)
      create(:price, product: product, brand: brand_b, quality: quality, value: 10.0)
      create(:price, product: product, brand: brand_c, quality: quality, value: 12.0)

      items = [
        {
          descripcion: '2 cuadernos 100 hojas',
          cantidad: 2,
          atributos: { hojas: 100 }
        }
      ]

      result = described_class.new(items).call

      expect(result[:unmatched_items]).to eq([])
      expect(result[:proposals][:economico][:total]).to eq(16.0)
      expect(result[:proposals][:balanceado][:total]).to eq(20.0)
      expect(result[:proposals][:premium][:total]).to eq(24.0)
    end

    it 'envia a unmatched los items sin coincidencia' do
      items = [
        { descripcion: 'Producto inexistente', cantidad: 1, atributos: {} }
      ]

      result = described_class.new(items).call

      expect(result[:unmatched_items].size).to eq(1)
      expect(result[:proposals][:economico][:items]).to eq([])
    end

    it 'prioriza el mejor score de producto aunque exista otra opcion mas barata' do
      matched_product = create(:product, name: 'Tempera 250 ml', normalized_name: 'tempera-250-ml')
      cheap_wrong_product = create(:product, name: 'Cartulina negra', normalized_name: 'cartulina-negra')

      brand = create(:brand, name: 'Marca X')
      quality = create(:quality, level: 'estandar')

      matched_price = create(:price, product: matched_product, brand: brand, quality: quality, value: 9.0)
      wrong_price = create(:price, product: cheap_wrong_product, brand: brand, quality: quality, value: 0.9)

      matcher = instance_double(ProductMatcherService)
      allow(ProductMatcherService).to receive(:new).and_return(matcher)
      allow(matcher).to receive(:call).and_return([
        { product: matched_product, score: 90, prices: [matched_price] },
        { product: cheap_wrong_product, score: 35, prices: [wrong_price] }
      ])

      items = [
        { descripcion: 'frascos de tempera blanco, celeste, anaranjado y piel de 250ml.', cantidad: 4, atributos: { volumen_ml: 250 } }
      ]

      result = described_class.new(items).call
      selected = result[:proposals][:economico][:items].first

      expect(selected[:matched_product_id]).to eq(matched_product.id)
      expect(selected[:unit_value]).to eq(9.0)
    end
  end
end
