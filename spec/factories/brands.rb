FactoryBot.define do
  factory :brand do
    sequence(:name) { |n| "Marca #{n}" }
    country { "Perú" }
  end
end
