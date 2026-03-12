require 'rails_helper'

RSpec.describe BudgetCalculatorService, type: :service do
  describe '#total' do
    it 'suma cantidad por precio de todos los items' do
      items = [
        { descripcion: 'Producto A', cantidad: 2, precio: 10.5 },
        { descripcion: 'Producto B', cantidad: 3, precio: 4.0 }
      ]

      total = described_class.new(items).total

      expect(total).to eq(33.0)
    end

    it 'retorna 0 cuando no hay items' do
      total = described_class.new([]).total

      expect(total).to eq(0)
    end

    it 'tolera items sin precio y los considera como 0' do
      items = [
        { descripcion: 'Cuaderno', cantidad: 2, precio: nil },
        { descripcion: 'Lapiz', cantidad: 3, precio: 1.5 }
      ]

      total = described_class.new(items).total

      expect(total).to eq(4.5)
    end
  end
end