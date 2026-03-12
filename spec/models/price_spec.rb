require 'rails_helper'

RSpec.describe Price, type: :model do
  it { should belong_to(:product) }
  it { should belong_to(:brand) }
  it { should belong_to(:quality) }
  it { should validate_presence_of(:value) }
  it { should validate_numericality_of(:value).is_greater_than(0) }

  describe 'reglas de negocio' do
    it 'asigna public_uuid al crear' do
      price = create(:price)

      expect(price.public_uuid).to match(/\A[0-9a-f\-]{36}\z/)
    end

    it 'no permite crear un precio sin marca, producto o calidad' do
      expect(build(:price, product: nil)).not_to be_valid
      expect(build(:price, brand: nil)).not_to be_valid
      expect(build(:price, quality: nil)).not_to be_valid
    end

    it 'no permite valores en cero o negativos' do
      expect(build(:price, value: 0)).not_to be_valid
      expect(build(:price, value: -10.5)).not_to be_valid
    end

    it 'permite un precio con atributos opcionales en nil' do
      price = build(:price, unit: nil, unit_quantity: nil, date: nil)
      expect(price).to be_valid
    end

    it 'permite crear precios distintos para la misma combinación producto-marca-calidad si cambian unidad o fecha' do
      price1 = create(:price, unit: 'unidad', date: Date.today)
      price2 = build(:price, product: price1.product, brand: price1.brand, quality: price1.quality, unit: 'caja', date: Date.today)
      expect(price2).to be_valid
    end

    it 'permite precios duplicados para la misma combinación y fecha cuando no hay validación de unicidad' do
      price1 = create(:price, unit: 'unidad', unit_quantity: 1, date: Date.today)
      price2 = build(:price,
                     product: price1.product,
                     brand: price1.brand,
                     quality: price1.quality,
                     unit: 'unidad',
                     unit_quantity: 1,
                     date: Date.today)

      expect(price2).to be_valid
    end
  end
end
