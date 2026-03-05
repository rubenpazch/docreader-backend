FactoryBot.define do
  factory :price do
    value { 10.0 }
    unit { "unidad" }
    unit_quantity { 1 }
    date { Date.today }
    association :product
    association :brand
    association :quality
  end
end
