require 'rails_helper'

RSpec.describe ItemParserService, type: :service do
  describe '#parse_items' do
    it 'retorna arreglo vacio cuando el texto es nil' do
      result = described_class.new(nil).parse_items

      expect(result).to eq([])
    end

    it 'parsea lineas con cantidad explicita' do
      text = "2 Azucar\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'Azucar', cantidad: 2, atributos: {} }
      ])
    end

    it 'asigna cantidad 1 cuando la linea no trae cantidad' do
      text = "Cuaderno\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'Cuaderno', cantidad: 1, atributos: {} }
      ])
    end

    it 'parsea lineas sin precio para listas de utiles' do
      text = "2 Cuadernos de 100 hojas tamano grande\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        {
          descripcion: 'Cuadernos de 100 hojas tamano grande',
          cantidad: 2,
          atributos: { hojas: 100, tamano: 'grande' }
        }
      ])
    end

    it 'extrae atributo de paquete x N' do
      text = "Plumones indelebles x 12\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        {
          descripcion: 'Plumones indelebles x 12',
          cantidad: 1,
          atributos: { paquete: 12 }
        }
      ])
    end

    it 'procesa lineas en texto mixto y conserva las parseables' do
      text = "Linea invalida\n3 Pan\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'Pan', cantidad: 3, atributos: {} }
      ])
    end

    it 'ignora encabezados y ruido OCR comun' do
      text = "LISTA DE MATERIALES\nCentro de Atencion y Desarrollo Infantil\n01 Cuaderno rayado de 100 hojas\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'Cuaderno rayado de 100 hojas', cantidad: 1, atributos: { hojas: 100 } }
      ])
    end

    it 'interpreta O2 como 02 al inicio de linea' do
      text = "O2 cintas de embalaje gruesa\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'cintas de embalaje gruesa', cantidad: 2, atributos: {} }
      ])
    end

    it 'no interpreta dimensiones como paquete' do
      text = "01 block de cartulina de colores 36 hojas 24.5 x 34.5 cm.\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        {
          descripcion: 'block de cartulina de colores 36 hojas 24.5 x 34.5 cm.',
          cantidad: 1,
          atributos: { hojas: 36 }
        }
      ])
    end

    it 'no toma carta desde la palabra descartables' do
      text = "01 paquete de tenedores descartables\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'paquete de tenedores descartables', cantidad: 1, atributos: {} }
      ])
    end

    it 'interpreta lineas de gramos como cantidad 1 con atributo de peso' do
      text = "250 gr. de harina\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'harina', cantidad: 1, atributos: { peso_gramos: 250 } }
      ])
    end

    it 'ignora lineas de recomendaciones administrativas' do
      text = "No esta permitido traer mochila con ruedas\n01 caja de crayolas\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'caja de crayolas', cantidad: 1, atributos: {} }
      ])
    end

    it 'normaliza error OCR oma -> goma' do
      text = "01 oma trasparente para slime de 120ml\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'goma trasparente para slime de 120ml', cantidad: 1, atributos: { volumen_ml: 120 } }
      ])
    end

    it 'ignora linea de cartuchera administrativa' do
      text = "Enuna cartuchera con nombre debe ir (Ldpiz, colores, crayolas, tajador, tijera, goma)\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([])
    end

    it 'ignora fragmento administrativo suelto con cada una con nombre' do
      text = "goma, cada una con nombre\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([])
    end

    it 'normaliza 12 botones reciclados como un item tipo docena' do
      text = "12 botones reciclados\n"

      result = described_class.new(text).parse_items

      expect(result).to eq([
        { descripcion: 'botones reciclados', cantidad: 1, atributos: { paquete: 12 } }
      ])
    end
  end
end