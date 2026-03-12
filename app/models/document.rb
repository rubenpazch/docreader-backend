  class Document < ApplicationRecord
    has_one_attached :file
    before_validation :assign_public_uuid, on: :create

    validates :file, attached: true, content_type: ['application/pdf', 'image/png', 'image/jpeg']
    validates :public_uuid, presence: true, uniqueness: true

    # Usa el servicio para extraer ítems del texto extraído
    def extracted_items
      @extracted_items ||= ItemParserService.new(extracted_text).parse_items
    end

    # Usa el servicio para calcular el total del presupuesto
    def presupuesto_total
      BudgetCalculatorService.new(extracted_items).total
    end

    # Construye propuestas de presupuesto con alternativas de precio
    def presupuesto_propuestas
      @presupuesto_propuestas ||= BudgetProposalService.new(extracted_items).call
    end

    # Usa el servicio para extraer texto del archivo adjunto
    def extract_text
      return unless file.attached?
      text = TextExtractionService.new(file).extract_text
      update_column(:extracted_text, text)
      text
    end

    private

    def assign_public_uuid
      self.public_uuid ||= SecureRandom.uuid
    end
  end
