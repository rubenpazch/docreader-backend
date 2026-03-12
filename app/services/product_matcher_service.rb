class ProductMatcherService
  MAX_RESULTS = 5
  CANDIDATE_LIMIT = 100
  MIN_SCORE = 25
  STOPWORDS = %w[
    de del la las los y con para por un una en el al
    color colores tamano tamafio nombre hoja hojas paquete paquetes
    unidad unidades caja estuche block pliego pliegos
  ].freeze

  OCR_SYNONYMS = {
    'ldpiz' => 'lapiz',
    'ldpices' => 'lapices',
    'disefio' => 'diseno',
    'tamafio' => 'tamano',
    'pequefio' => 'pequeno',
    'ofdicios' => 'oficio',
    'oficios' => 'oficio',
    'fdelder' => 'folder',
    'metdlica' => 'metalica',
    'estd' => 'esta',
    'enuna' => 'en una',
    'pafio' => 'pano',
    'trasparente' => 'transparente',
    'mdgico' => 'magico'
  }.freeze

  def initialize(item, scope: Product.all)
    @item = item || {}
    @scope = scope
  end

  def call
    query = @item[:descripcion].to_s.sub(/^\d+\s+/, '')
    return [] if query.strip.empty?

    tokens = normalize_tokens(query)
    return [] if tokens.empty? && query.strip.length < 3

    candidates = candidate_scope(tokens)

    candidates.map do |product|
      score = score_product(product, query, tokens)
      next if score < MIN_SCORE

      {
        product: product,
        score: score,
        prices: product.prices.to_a
      }
    end.compact.sort_by { |m| -m[:score] }.first(MAX_RESULTS)
  end

  private

  def candidate_scope(tokens)
    scoped = @scope.left_joins(:product_aliases)
    filtered_tokens = tokens.first(8)
    normalized_query = normalize_text(@item[:descripcion])

    unless normalized_query.include?('perf')
      scoped = scoped.where("products.name NOT LIKE 'Perf Product %'")
    end

    if filtered_tokens.any?
      scoped = if postgres?
                 apply_postgres_token_filter(scoped, filtered_tokens)
               else
                 apply_generic_token_filter(scoped, filtered_tokens)
               end
    end

    scoped.includes(:product_aliases, prices: [:brand, :quality]).distinct.limit(CANDIDATE_LIMIT)
  end

  def apply_postgres_token_filter(scoped, tokens)
    patterns = tokens.map { |token| "%#{ActiveRecord::Base.sanitize_sql_like(token)}%" }
    clauses = []
    binds = []

    patterns.each do |pattern|
      clauses << 'products.name ILIKE ?'
      clauses << 'products.normalized_name ILIKE ?'
      clauses << 'products.description ILIKE ?'
      clauses << 'products.category ILIKE ?'
      clauses << 'product_aliases.name ILIKE ?'
      5.times { binds << pattern }
    end

    scoped.where(clauses.join(' OR '), *binds)
  end

  def apply_generic_token_filter(scoped, tokens)
    patterns = tokens.map { |token| "%#{ActiveRecord::Base.sanitize_sql_like(token)}%" }
    clauses = []
    binds = []

    patterns.each do |pattern|
      clauses << 'LOWER(products.name) LIKE ?'
      clauses << 'LOWER(products.normalized_name) LIKE ?'
      clauses << 'LOWER(products.description) LIKE ?'
      clauses << 'LOWER(products.category) LIKE ?'
      clauses << 'LOWER(product_aliases.name) LIKE ?'
      5.times { binds << pattern }
    end

    scoped.where(clauses.join(' OR '), *binds)
  end

  def score_product(product, query, tokens)
    corpus = product_corpus(product)
    normalized_corpus = normalize_text(corpus)
    normalized_query = normalize_text(query)

    score = 0

    normalized_name = normalize_text(product.name.to_s)
    score += 60 if normalized_query.include?(normalized_name) || normalized_name.include?(normalized_query)

    alias_hit = product.product_aliases.any? do |product_alias|
      alias_text = normalize_text(product_alias.name.to_s)
      next false if alias_text.length < 6

      normalized_query.include?(alias_text) || alias_text.include?(normalized_query)
    end
    score += 45 if alias_hit

    candidate_tokens = normalize_tokens(corpus)
    overlap = token_overlap(tokens, candidate_tokens)
    score += (overlap * 40).round
    score += token_intersection_count(tokens, candidate_tokens) * 8

    attrs = @item[:atributos] || {}
    score += 10 if attrs[:hojas] && normalized_corpus.match?(/\b#{attrs[:hojas]}\b/)
    score += 10 if attrs[:tamano] && normalized_corpus.include?(normalize_text(attrs[:tamano]))
    score += 10 if attrs[:paquete] && normalized_corpus.match?(/\b#{attrs[:paquete]}\b/)

    score
  end

  def product_corpus(product)
    [
      product.name,
      product.normalized_name,
      product.description,
      product.category,
      product.product_aliases.map(&:name).join(' ')
    ].compact.join(' ')
  end

  def token_overlap(query_tokens, candidate_tokens)
    return 0.0 if query_tokens.empty?

    common = query_tokens.intersection(candidate_tokens)
    common.length.to_f / query_tokens.length
  end

  def token_intersection_count(query_tokens, candidate_tokens)
    query_tokens.intersection(candidate_tokens).length
  end

  def normalize_tokens(text)
    normalize_text(text)
      .split
      .map { |token| canonical_token(token) }
      .reject { |token| STOPWORDS.include?(token) }
      .reject { |token| token.match?(/\A\d{1,2}\z/) }
      .reject { |token| token.length < 3 && token !~ /\A\d+\z/ }
      .uniq
  end

  def canonical_token(token)
    token = OCR_SYNONYMS[token] || token

    return token if token.match?(/\A\d+\z/)

    if token.length > 5 && token.end_with?('es')
      token[0...-2]
    elsif token.length > 4 && token.end_with?('s')
      token[0...-1]
    else
      token
    end
  end

  def normalize_text(text)
    I18n.transliterate(text.to_s.downcase)
      .gsub(/[^a-z0-9\s]/, ' ')
      .squeeze(' ')
      .strip
  end

  def postgres?
    ActiveRecord::Base.connection.adapter_name.downcase.include?('postgres')
  end
end
