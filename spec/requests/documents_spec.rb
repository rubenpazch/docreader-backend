require 'rails_helper'
require 'stringio'

RSpec.describe 'Documents', type: :request do
  def json_body
    JSON.parse(response.body)
  end

  def uploaded_pdf
    tempfile = Tempfile.new(['lista', '.pdf'])
    tempfile.write('%PDF-1.4 fake')
    tempfile.rewind
    Rack::Test::UploadedFile.new(tempfile.path, 'application/pdf')
  end

  describe 'POST /documents' do
    it 'crea un documento cuando recibe archivo valido' do
      post '/documents', params: { document: { file: uploaded_pdf } }

      expect(response).to have_http_status(:created)
      expect(json_body['id']).to be_present
      expect(json_body['public_uuid']).to match(/\A[0-9a-f\-]{36}\z/)
      expect(json_body['message']).to eq('File uploaded successfully')
    end

    it 'retorna bad request cuando no recibe el parametro document' do
      post '/documents', params: { document: {} }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /documents/:id/extract' do
    it 'devuelve texto, items parseados y propuestas por escenario' do
      product = create(:product, name: 'Cuaderno 100 hojas grande', normalized_name: 'cuaderno-100-hojas-grande')
      create(:product_alias, product: product, name: 'Cuadernos de 100 hojas tamano grande')

      quality = create(:quality, level: 'estandar')
      brand_cheap = create(:brand, name: 'Marca Economica')
      brand_premium = create(:brand, name: 'Marca Premium')
      create(:price, product: product, quality: quality, brand: brand_cheap, value: 9.0)
      create(:price, product: product, quality: quality, brand: brand_premium, value: 12.0)

      document = Document.new
      document.file.attach(io: StringIO.new('pdf'), filename: 'lista.pdf', content_type: 'application/pdf')
      document.save!

      allow_any_instance_of(TextExtractionService).to receive(:extract_text).and_return('2 Cuadernos de 100 hojas tamano grande')

      get "/documents/#{document.id}/extract"

      expect(response).to have_http_status(:ok)
      expect(json_body['text']).to eq('2 Cuadernos de 100 hojas tamano grande')
      expect(json_body['items']).to eq([
        {
          'descripcion' => 'Cuadernos de 100 hojas tamano grande',
          'cantidad' => 2,
          'atributos' => { 'hojas' => 100, 'tamano' => 'grande' }
        }
      ])

      proposals = json_body['proposals']['proposals']
      expect(proposals['economico']['items'].size).to eq(1)
      expect(proposals['economico']['total']).to eq(18.0)
      expect(proposals['premium']['total']).to eq(24.0)
      expect(json_body['proposals']['unmatched_items']).to eq([])
    end

    it 'marca items sin match en unmatched_items' do
      document = Document.new
      document.file.attach(io: StringIO.new('pdf'), filename: 'lista.pdf', content_type: 'application/pdf')
      document.save!

      allow_any_instance_of(TextExtractionService).to receive(:extract_text).and_return('3 Producto imposible de encontrar')

      get "/documents/#{document.id}/extract"

      expect(response).to have_http_status(:ok)
      expect(json_body['proposals']['proposals']['economico']['items']).to eq([])
      expect(json_body['proposals']['unmatched_items']).to eq([
        {
          'descripcion' => 'Producto imposible de encontrar',
          'cantidad' => 3,
          'atributos' => {}
        }
      ])
    end

    it 'ejecuta el flujo completo desde POST hasta propuestas con match y unmatched' do
      cuaderno = create(
        :product,
        name: 'Cuaderno 100 hojas grande',
        normalized_name: 'cuaderno-100-hojas-grande',
        description: 'cuaderno rayado 100 hojas tamano grande',
        category: 'cuadernos'
      )
      create(:product_alias, product: cuaderno, name: 'Cuadernos de 100 hojas tamano grande')

      plumon = create(
        :product,
        name: 'Plumon indeleble x 12',
        normalized_name: 'plumon-indeleble-x-12',
        description: 'plumones indelebles set por 12',
        category: 'marcadores'
      )
      create(:product_alias, product: plumon, name: 'Plumones indelebles x 12')

      quality = create(:quality, level: 'estandar')

      create(:price, product: cuaderno, quality: quality, brand: create(:brand, name: 'Marca C1'), value: 9.0)
      create(:price, product: cuaderno, quality: quality, brand: create(:brand, name: 'Marca C2'), value: 10.0)
      create(:price, product: cuaderno, quality: quality, brand: create(:brand, name: 'Marca C3'), value: 12.0)

      create(:price, product: plumon, quality: quality, brand: create(:brand, name: 'Marca P1'), value: 14.0)
      create(:price, product: plumon, quality: quality, brand: create(:brand, name: 'Marca P2'), value: 16.0)
      create(:price, product: plumon, quality: quality, brand: create(:brand, name: 'Marca P3'), value: 20.0)

      post '/documents', params: { document: { file: uploaded_pdf } }
      expect(response).to have_http_status(:created)
      document_id = json_body['id']

      extracted_text = "2 Cuadernos de 100 hojas tamano grande\n1 Plumones indelebles x 12\n3 zzzxxyy qwerty"
      allow_any_instance_of(TextExtractionService).to receive(:extract_text).and_return(extracted_text)

      get "/documents/#{document_id}/extract"

      expect(response).to have_http_status(:ok)
      expect(json_body['text']).to eq(extracted_text)
      expect(json_body['items'].size).to eq(3)

      proposals = json_body['proposals']['proposals']
      expect(proposals['economico']['items'].size).to eq(2)
      expect(proposals['economico']['total']).to eq(32.0)
      expect(proposals['balanceado']['total']).to eq(36.0)
      expect(proposals['premium']['total']).to eq(44.0)

      expect(json_body['proposals']['unmatched_items']).to eq([
        {
          'descripcion' => 'zzzxxyy qwerty',
          'cantidad' => 3,
          'atributos' => {}
        }
      ])

      expect(Document.find(document_id).extracted_text).to eq(extracted_text)
    end

    it 'retorna not found cuando el documento no existe' do
      get '/documents/999999/extract'

      expect(response).to have_http_status(:not_found)
    end

    it 'permite extraer usando public_uuid' do
      product = create(:product, name: 'Cuaderno 100 hojas grande', normalized_name: 'cuaderno-100-hojas-grande')
      create(:product_alias, product: product, name: 'Cuadernos de 100 hojas tamano grande')
      quality = create(:quality, level: 'estandar')
      create(:price, product: product, quality: quality, brand: create(:brand), value: 9.0)

      document = Document.new
      document.file.attach(io: StringIO.new('pdf'), filename: 'lista.pdf', content_type: 'application/pdf')
      document.save!

      allow_any_instance_of(TextExtractionService).to receive(:extract_text).and_return('2 Cuadernos de 100 hojas tamano grande')

      get "/documents/#{document.public_uuid}/extract"

      expect(response).to have_http_status(:ok)
      expect(json_body['items'].first['descripcion']).to eq('Cuadernos de 100 hojas tamano grande')
    end
  end
end
