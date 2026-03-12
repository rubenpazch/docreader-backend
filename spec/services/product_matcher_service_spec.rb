require 'rails_helper'

RSpec.describe ProductMatcherService, type: :service do
  describe '#call' do
    it 'encuentra productos por nombre' do
      product = create(:product, name: 'Cuaderno 100 hojas grande', normalized_name: 'cuaderno-100-hojas-grande')
      create(:price, product: product)

      item = {
        descripcion: '2 cuadernos de 100 hojas tamano grande',
        cantidad: 2,
        atributos: { hojas: 100, tamano: 'grande' }
      }

      matches = described_class.new(item).call

      expect(matches).not_to be_empty
      expect(matches.first[:product].id).to eq(product.id)
      expect(matches.first[:score]).to be > 0
    end

    it 'encuentra productos por alias' do
      product = create(:product, name: 'Plumon indeleble', normalized_name: 'plumon-indeleble')
      create(:product_alias, product: product, name: 'Plumones indelebles x 12')
      create(:price, product: product)

      item = {
        descripcion: 'Plumones indelebles x 12',
        cantidad: 1,
        atributos: { paquete: 12 }
      }

      matches = described_class.new(item).call

      expect(matches).not_to be_empty
      expect(matches.map { |m| m[:product].id }).to include(product.id)
    end

    it 'retorna vacio cuando no hay descripcion' do
      matches = described_class.new({ descripcion: nil }).call

      expect(matches).to eq([])
    end

    it 'retorna productos sin precios y proposal decide si son utilizables' do
      product = create(:product, name: 'Cartuchera escolar', normalized_name: 'cartuchera-escolar')

      matches = described_class.new({ descripcion: 'Cartuchera escolar', cantidad: 1, atributos: {} }).call

      expect(matches.first[:product].id).to eq(product.id)
      expect(matches.first[:prices]).to eq([])
    end

    it 'evita usar productos de benchmark para consultas normales' do
      perf_product = create(:product, name: 'Perf Product 999', normalized_name: 'perf-product-999')
      create(:price, product: perf_product)

      matches = described_class.new({ descripcion: 'cuaderno escolar', cantidad: 1, atributos: {} }).call

      expect(matches.map { |m| m[:product].id }).not_to include(perf_product.id)
    end

    it 'normaliza errores OCR comunes al matchear' do
      product = create(:product, name: 'Lapices de colores triangulares', normalized_name: 'lapices-colores-triangulares')
      create(:price, product: product)

      matches = described_class.new({ descripcion: 'estuche de ldpices de colores', cantidad: 1, atributos: {} }).call

      expect(matches.map { |m| m[:product].id }).to include(product.id)
    end

    it 'matchea papel bond oficio aunque la descripcion sea larga' do
      product = create(:product, name: 'Papel bond oficio blanco', normalized_name: 'papel-bond-oficio-blanco')
      create(:product_alias, product: product, name: 'pliegos de papel bond oficio blanco')
      create(:price, product: product)

      matches = described_class.new({ descripcion: 'pliegos de papel bond 8 oficios blanco doblado', cantidad: 8, atributos: {} }).call

      expect(matches.map { |m| m[:product].id }).to include(product.id)
    end
    
    it 'matchea cartulina corrugada con colores detallados' do
      product = create(:product, name: 'Cartulina corrugada metalica', normalized_name: 'cartulina-corrugada-metalica')
      create(:product_alias, product: product, name: 'pliego de cartulina corrugada metalica')
      create(:price, product: product, value: 2.0)

      matches = described_class.new({ descripcion: 'pliego de cartulina corrugada metdlica plateado, rojo, azul y fucsia', cantidad: 4, atributos: {} }).call

      expect(matches.map { |m| m[:product].id }).to include(product.id)
    end

    it 'matchea papel crepe con lista de colores' do
      product = create(:product, name: 'Papel crepe de colores', normalized_name: 'papel-crepe-colores')
      create(:product_alias, product: product, name: 'pliegos de papel crepe colores')
      create(:price, product: product, value: 1.8)

      matches = described_class.new({ descripcion: 'pliegos de papel crepe colores: marron, verde, rojo y morado', cantidad: 4, atributos: {} }).call

      expect(matches.map { |m| m[:product].id }).to include(product.id)
    end

    it 'matchea tempera con colores y volumen OCR' do
      product = create(:product, name: 'Tempera 250 ml', normalized_name: 'tempera-250-ml')
      create(:product_alias, product: product, name: 'frascos de tempera de 250ml')
      create(:price, product: product, value: 5.5)

      matches = described_class.new({ descripcion: 'frascos de tempera blanco, celeste, anaranjado y piel de 250ml.', cantidad: 4, atributos: { volumen_ml: 250 } }).call

      expect(matches.map { |m| m[:product].id }).to include(product.id)
    end
  end
end
