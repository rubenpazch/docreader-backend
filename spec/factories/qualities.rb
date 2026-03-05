FactoryBot.define do
  factory :quality do
    sequence(:level) { |n| "alta#{n}" }
    description { "Calidad alta" }
    quality_factor { 1.0 }
  end
end
