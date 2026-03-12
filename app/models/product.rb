class Product < ApplicationRecord
  has_many :product_aliases, dependent: :destroy
  has_many :prices, dependent: :destroy
  has_many :brands, through: :prices
  has_many :qualities, through: :prices

  before_validation :assign_public_uuid, on: :create

  validates :public_uuid, presence: true, uniqueness: true

  private

  def assign_public_uuid
    self.public_uuid ||= SecureRandom.uuid
  end
end
