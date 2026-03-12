require 'rails_helper'
require 'stringio'

RSpec.describe Document, type: :model do
  def attach_pdf(document)
    document.file.attach(
      io: StringIO.new('pdf content'),
      filename: 'lista.pdf',
      content_type: 'application/pdf'
    )
  end

  describe '#extract_text' do
    it 'asigna public_uuid al crear documento con archivo valido' do
      document = described_class.new
      attach_pdf(document)

      document.save!

      expect(document.public_uuid).to match(/\A[0-9a-f\-]{36}\z/)
    end

    it 'retorna nil cuando no hay archivo adjunto' do
      document = described_class.new

      expect(document.extract_text).to be_nil
    end

    it 'guarda extracted_text y retorna el texto extraido' do
      document = described_class.new
      attach_pdf(document)
      document.save!

      extractor = instance_double('TextExtractionService', extract_text: '2 Cuadernos')
      allow(TextExtractionService).to receive(:new).with(document.file).and_return(extractor)

      result = document.extract_text

      expect(result).to eq('2 Cuadernos')
      expect(document.reload.extracted_text).to eq('2 Cuadernos')
    end
  end

  describe '#extracted_items' do
    it 'memoiza el parseo para no ejecutar el servicio multiples veces' do
      document = described_class.new(extracted_text: '2 Cuadernos')
      attach_pdf(document)
      document.save!
      parser = instance_double('ItemParserService', parse_items: [{ descripcion: 'Cuadernos', cantidad: 2, atributos: {} }])
      allow(ItemParserService).to receive(:new).with('2 Cuadernos').and_return(parser)

      first = document.extracted_items
      second = document.extracted_items

      expect(first).to eq(second)
      expect(ItemParserService).to have_received(:new).once
    end
  end

  describe '#presupuesto_propuestas' do
    it 'memoiza propuestas para evitar recalculo' do
      document = described_class.new(extracted_text: '2 Cuadernos')
      attach_pdf(document)
      document.save!
      allow(document).to receive(:extracted_items).and_return([{ descripcion: 'Cuadernos', cantidad: 2, atributos: {} }])

      service = instance_double('BudgetProposalService', call: { proposals: {}, unmatched_items: [] })
      allow(BudgetProposalService).to receive(:new).and_return(service)

      first = document.presupuesto_propuestas
      second = document.presupuesto_propuestas

      expect(first).to eq(second)
      expect(BudgetProposalService).to have_received(:new).once
    end
  end
end
