FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Producto #{n}" }
    sequence(:normalized_name) { |n| "producto-#{n}" }
    description { "Descripción de producto" }
    category { "útiles" }
  end
end
