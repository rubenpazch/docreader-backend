class ItemParserService
  SCHOOL_KEYWORDS = %w[
    cuaderno cartulina papel hoja hojas block folder archivador
    lapiz lapices colores crayola plumon plumones tajador tijera goma
    plastilina tempera silicona micas maskin cinta lana yute chenille
    cuento palitos arroz maicena harina semola fideo algodon hisopos
    botones lentejuelas ojos movibles toalla mochila cartuchera
  ].freeze

  NOISE_PATTERNS = [
    /\Alista de materiales\b/i,
    /\Asala\b/i,
    /\Acentro de atencion/i,
    /\Alas marcas indicadas/i,
    /\Apapis y mamis/i,
    /\Autiles personales/i,
    /\Amateriales reciclados/i,
    /\Ano esta permitido/i,
    /\Aory\z/i,
    /\Aoly\z/i,
    /\Agarobalo\z/i
  ].freeze

  # Recibe texto y devuelve array de hashes { descripcion, cantidad, atributos }
  def initialize(text)
    @text = text
  end

  def parse_items
    return [] unless @text.present?

    items = []
    @text.each_line do |line|
      parsed = parse_line(line)
      items << parsed if parsed
    end

    items
  end

  private

  def parse_line(raw_line)
    line = normalize_line(raw_line)
    return nil if line.blank?
    return nil if ignore_line?(line)

    cantidad, descripcion = extract_quantity_and_description(line)
    return nil if descripcion.blank?

    attributes = extract_attributes(descripcion)
    cantidad = normalize_quantity(cantidad, descripcion, attributes)
    descripcion = sanitize_description(descripcion)

    {
      descripcion: descripcion,
      cantidad: cantidad,
      atributos: attributes
    }
  end

  def normalize_line(raw_line)
    line = raw_line.to_s.strip
    line = line.gsub(/^[\-\*\u2022\.]\s*/, '')
    line = line.gsub(/^e\s+/i, '')
    line = line.sub(/\A([oO])(?=\d)/, '0')
    line = line.sub(/\Aoma\b/i, 'goma')
    line = line.squeeze(' ').strip
    line
  end

  def ignore_line?(line)
    normalized = normalize_text(line)
    return true if normalized.blank?
    return true if normalized.length < 3
    return true if NOISE_PATTERNS.any? { |pattern| normalized.match?(pattern) }
    return true if line.end_with?(':') && !line.match?(/\A\d+/)
    return true if advisory_line?(normalized)
    return true unless likely_material_line?(line, normalized)

    words = normalized.split
    return true if words.size >= 3 && words.all? { |word| word.length <= 3 }

    false
  end

  def advisory_line?(normalized)
    advisory_patterns = [
      /se recomienda/,
      /no est\w* permitido/,
      /deben asistir/,
      /deberan entregar/,
      /deberan estar/,
      /cartuchera con nombre debe ir/,
      /muda completa de ropa/,
      /cada una con nombre/
    ]

    advisory_patterns.any? { |pattern| normalized.match?(pattern) }
  end

  def likely_material_line?(line, normalized)
    return true if line.match?(/\A(?:\d{1,4}|un|una)\s+/i)

    SCHOOL_KEYWORDS.any? { |keyword| normalized.include?(keyword) }
  end

  def extract_quantity_and_description(line)
    match = line.match(/\A(\d{1,4}|un|una)\s+(.+)\z/i)
    return [1, line] unless match

    quantity_token = match[1]
    description = match[2].strip

    cantidad = quantity_token.match?(/\A\d+\z/) ? quantity_token.to_i : 1
    [cantidad, description]
  end

  def normalize_quantity(cantidad, descripcion, attributes)
    normalized_description = normalize_text(descripcion)

    if normalized_description.match?(/\bbotones?\b/) && !normalized_description.match?(/\bdocena\b/) && cantidad == 12
      attributes[:paquete] ||= 12
      return 1
    end

    if descripcion.match?(/\A(?:gr|g)\b/i)
      attributes[:peso_gramos] ||= cantidad
      return 1
    end

    if descripcion.match?(/\Aml\b/i)
      attributes[:volumen_ml] ||= cantidad
      return 1
    end

    cantidad
  end

  def sanitize_description(descripcion)
    cleaned = descripcion.sub(/\A(?:gr|g|ml)\.?\s*(?:de\s+)?/i, '').strip
    cleaned.sub(/\Aoma\b/i, 'goma')
  end

  def extract_attributes(descripcion)
    text = descripcion.downcase

    {
      hojas: extract_integer(text, /(\d+)\s*hojas?/i),
      tamano: extract_string(text, /\b(a4|oficio|carta|grande|pequeno|pequena|mediano|mediana)\b/i),
      paquete: extract_integer(text, /(?:\b(?:x|por)\s*)(\d{1,3})(?![.,]\d)\b/i),
      peso_gramos: extract_integer(text, /(\d+)\s*(?:gr|g)\b/i),
      volumen_ml: extract_integer(text, /(\d+)\s*ml\b/i),
      marca: extract_string(text, /marca\s+([a-z0-9\-\s]+)/i)
    }.compact
  end

  def extract_integer(text, regex)
    match = text.match(regex)
    match ? match[1].to_i : nil
  end

  def extract_string(text, regex)
    match = text.match(regex)
    match ? match[1].strip : nil
  end

  def normalize_text(text)
    I18n.transliterate(text.to_s.downcase)
      .gsub(/[^a-z0-9\s]/, ' ')
      .squeeze(' ')
      .strip
  end
end
