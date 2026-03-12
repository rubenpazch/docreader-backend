require 'rails_helper'
require 'benchmark'

RSpec.describe ProductMatcherService, type: :service do
  describe 'performance', :performance do
    it 'mantiene latencia razonable con catalogo grande sintetico' do
      skip 'Set RUN_PERF_SPECS=1 to run performance specs' unless ENV['RUN_PERF_SPECS'] == '1'

      catalog_size = (ENV['PERF_CATALOG_SIZE'] || 10_000).to_i
      threshold_ms = (ENV['PERF_MATCHER_THRESHOLD_MS'] || 250.0).to_f

      quality = create(:quality, level: "perf-level-#{SecureRandom.hex(4)}")
      brand = create(:brand, name: "PerfBrand-#{SecureRandom.hex(4)}")

      now = Time.current
      suffix = SecureRandom.hex(6)
      product_rows = Array.new(catalog_size) do |i|
        n = i + 1
        {
          name: "Perf Product #{suffix} #{n}",
          normalized_name: "perf-product-#{suffix}-#{n}",
          description: "catalogo performance item #{n}",
          category: 'utiles',
          created_at: now,
          updated_at: now
        }
      end

      Product.insert_all(product_rows)
      target = Product.find_by!(normalized_name: "perf-product-#{suffix}-#{catalog_size / 2}")
      ProductAlias.create!(product: target, name: "Cuaderno especial #{suffix} 100 hojas")
      Price.create!(product: target, brand: brand, quality: quality, value: 12.0, unit: 'unidad', unit_quantity: 1, date: Date.current)

      item = {
        descripcion: "Cuaderno especial #{suffix} 100 hojas",
        cantidad: 1,
        atributos: { hojas: 100 }
      }

      elapsed = Benchmark.realtime { described_class.new(item).call }
      elapsed_ms = elapsed * 1000.0

      expect(elapsed_ms).to be < threshold_ms
    end
  end
end
