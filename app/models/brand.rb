class Brand < ApplicationRecord
  has_many :prices, dependent: :destroy
  has_many :products, through: :prices
end
