require 'rails_helper'

RSpec.describe TextExtractionService, type: :service do
  let(:file) { instance_double('AttachedFile') }
  let(:blob_service) { instance_double('ActiveStorage::Service') }

  before do
    allow(ActiveStorage::Blob).to receive(:service).and_return(blob_service)
    allow(file).to receive(:key).and_return('abc123')
    allow(blob_service).to receive(:send).with(:path_for, 'abc123').and_return('/tmp/input.file')
  end

  describe '#extract_text' do
    it 'retorna nil cuando el archivo no esta adjunto' do
      allow(file).to receive(:attached?).and_return(false)

      result = described_class.new(file).extract_text

      expect(result).to be_nil
    end

    it 'extrae texto desde una imagen' do
      allow(file).to receive(:attached?).and_return(true)
      allow(file).to receive(:content_type).and_return('image/png')

      service = described_class.new(file)
      allow(service).to receive(:require).with('mini_magick').and_return(true)
      allow(service).to receive(:require).with('rtesseract').and_return(true)

      rtesseract = class_double('RTesseract').as_stubbed_const
      image_ocr = instance_double('RTesseract', to_s: 'texto imagen')
      allow(rtesseract).to receive(:new).with('/tmp/input.file').and_return(image_ocr)

      result = service.extract_text

      expect(result).to eq('texto imagen')
    end

    it 'extrae y concatena texto de cada pagina en un pdf' do
      allow(file).to receive(:attached?).and_return(true)
      allow(file).to receive(:content_type).and_return('application/pdf')
      allow(blob_service).to receive(:send).with(:path_for, 'abc123').and_return('/tmp/input.pdf')

      service = described_class.new(file)
      allow(service).to receive(:require).with('mini_magick').and_return(true)
      allow(service).to receive(:require).with('rtesseract').and_return(true)
      allow(service).to receive(:require).with('tmpdir').and_return(true)

      convert = class_double('MiniMagick::Tool::Convert').as_stubbed_const
      convert_builder = instance_double('ConvertBuilder')
      allow(convert_builder).to receive(:density)
      allow(convert_builder).to receive(:background)
      allow(convert_builder).to receive(:alpha)
      allow(convert_builder).to receive(:<<)
      allow(convert).to receive(:new).and_yield(convert_builder)

      allow(Dir).to receive(:mktmpdir).and_yield('/tmp/ocr-pages')
      allow(Dir).to receive(:[]).with('/tmp/ocr-pages/page-*.png').and_return([
        '/tmp/ocr-pages/page-002.png',
        '/tmp/ocr-pages/page-001.png'
      ])

      rtesseract = class_double('RTesseract').as_stubbed_const
      page1 = instance_double('RTesseract', to_s: 'pagina1 ')
      page2 = instance_double('RTesseract', to_s: 'pagina2')
      allow(rtesseract).to receive(:new).with('/tmp/ocr-pages/page-001.png').and_return(page1)
      allow(rtesseract).to receive(:new).with('/tmp/ocr-pages/page-002.png').and_return(page2)

      result = service.extract_text

      expect(result).to eq('pagina1 pagina2')
    end

    it 'retorna string vacio para tipos de archivo no soportados' do
      allow(file).to receive(:attached?).and_return(true)
      allow(file).to receive(:content_type).and_return('text/plain')

      service = described_class.new(file)
      allow(service).to receive(:require).with('mini_magick').and_return(true)
      allow(service).to receive(:require).with('rtesseract').and_return(true)

      result = service.extract_text

      expect(result).to eq('')
    end
  end
end