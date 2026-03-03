class AddExtractedTextToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :extracted_text, :text
  end
end
