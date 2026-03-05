class Price < ApplicationRecord
  belongs_to :product
  belongs_to :brand
  belongs_to :quality

  validates :value, presence: true, numericality: { greater_than: 0 }
end
