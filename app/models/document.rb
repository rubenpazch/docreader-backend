class Document < ApplicationRecord
  has_one_attached :file
  validates :file, attached: true, content_type: ['application/pdf', 'image/png', 'image/jpeg']

  def extract_text
    return unless file.attached? && file.content_type == 'application/pdf'
    file_path = ActiveStorage::Blob.service.send(:path_for, file.key)
    require 'pdf_ocr'
    text = PdfOcr::Pdf.new(file_path).to_s
    update_column(:extracted_text, text)
    text
  end
end
