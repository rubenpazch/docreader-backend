class DocumentsController < ApplicationController
  def create
    document = Document.new(document_params)
    if document.save
      render json: { id: document.id, message: 'File uploaded successfully' }, status: :created
    else
      render json: { errors: document.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def extract
    document = Document.find(params[:id])
    text = document.extract_text
    render json: { text: text }
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end
end
