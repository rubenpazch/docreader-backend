class Product < ApplicationRecord
  has_many :product_aliases, dependent: :destroy
end
