class DocumentsController < ApplicationController
  def create
    document = Document.new(document_params)
    if document.save
      render json: { id: document.id, public_uuid: document.public_uuid, message: 'File uploaded successfully' }, status: :created
    else
      render json: { errors: document.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def extract
    document = find_document(params[:id])
    text = document.extract_text
    render json: {
      text: text,
      items: document.extracted_items,
      proposals: document.presupuesto_propuestas
    }
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end

  def find_document(identifier)
    return Document.find(identifier) if identifier.to_s.match?(/\A\d+\z/)

    Document.find_by!(public_uuid: identifier)
  end
end
