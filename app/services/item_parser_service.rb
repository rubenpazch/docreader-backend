class ItemParserService
  # Recibe texto y devuelve array de hashes { descripcion, cantidad, precio }
  def initialize(text)
    @text = text
  end

  def parse_items
    return [] unless @text.present?
    items = []
    @text.each_line do |line|
      if line =~ /^(\d+)?\s*([^\d\n]+?)\s*S\/.\s*(\d+[.,]?\d*)/i
        cantidad = $1 ? $1.to_i : 1
        descripcion = $2.strip
        precio = $3.tr(',', '.').to_f
        items << { descripcion: descripcion, cantidad: cantidad, precio: precio }
      end
    end
    items
  end
end
