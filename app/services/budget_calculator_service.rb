class BudgetCalculatorService
  # Recibe array de items { descripcion, cantidad, precio }
  def initialize(items)
    @items = items
  end

  def total
    @items.sum { |item| item[:cantidad] * item[:precio] }
  end
end
