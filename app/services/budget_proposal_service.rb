class BudgetProposalService
  SCENARIOS = {
    economico: :min,
    balanceado: :mid,
    premium: :max
  }.freeze

  def initialize(items, matcher_class: ProductMatcherService)
    @items = items || []
    @matcher_class = matcher_class
  end

  def call
    scenario_items = {
      economico: [],
      balanceado: [],
      premium: []
    }
    unmatched_items = []

    @items.each do |item|
      options = build_options(item)

      if options.empty?
        unmatched_items << item
        next
      end

      SCENARIOS.each do |scenario, strategy|
        selected = pick_option(options, strategy)
        scenario_items[scenario] << build_line(item, selected)
      end
    end

    {
      proposals: {
        economico: build_proposal_payload(scenario_items[:economico]),
        balanceado: build_proposal_payload(scenario_items[:balanceado]),
        premium: build_proposal_payload(scenario_items[:premium])
      },
      unmatched_items: unmatched_items
    }
  end

  private

  def build_options(item)
    matches = @matcher_class.new(item).call
    return [] if matches.empty?

    # Prioritize semantic accuracy: use prices from the best-scoring product match.
    best_match = matches.max_by { |match| match[:score].to_f }
    return [] unless best_match

    best_match[:prices].map do |price|
      {
        product: best_match[:product],
        price: price,
        score: best_match[:score]
      }
    end
  end

  def pick_option(options, strategy)
    sorted = options.sort_by { |option| option[:price].value.to_f }

    case strategy
    when :min
      sorted.first
    when :max
      sorted.last
    when :mid
      sorted[sorted.length / 2]
    else
      sorted.first
    end
  end

  def build_line(item, selected)
    quantity = item[:cantidad].to_i
    unit_value = selected[:price].value.to_f

    {
      requested_description: item[:descripcion],
      quantity: quantity,
      matched_product_id: selected[:product].id,
      matched_product_name: selected[:product].name,
      brand: selected[:price].brand.name,
      quality: selected[:price].quality.level,
      unit: selected[:price].unit,
      unit_quantity: selected[:price].unit_quantity,
      unit_value: unit_value,
      subtotal: quantity * unit_value,
      match_score: selected[:score]
    }
  end

  def build_proposal_payload(lines)
    {
      items: lines,
      total: lines.sum { |line| line[:subtotal].to_f }
    }
  end
end
