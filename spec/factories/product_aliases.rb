FactoryBot.define do
  factory :product_alias do
    sequence(:name) { |n| "alias-#{n}" }
    association :product
  end
end
