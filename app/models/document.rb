  class Document < ApplicationRecord
    has_one_attached :file
    validates :file, attached: true, content_type: ['application/pdf', 'image/png', 'image/jpeg']

    # Usa el servicio para extraer ítems del texto extraído
    def extracted_items
      ItemParserService.new(extracted_text).parse_items
    end

    # Usa el servicio para calcular el total del presupuesto
    def presupuesto_total
      BudgetCalculatorService.new(extracted_items).total
    end

    # Usa el servicio para extraer texto del archivo adjunto
    def extract_text
      return unless file.attached?
      text = TextExtractionService.new(file).extract_text
      update_column(:extracted_text, text)
      text
    end
  end
