class Brand < ApplicationRecord
  has_many :prices, dependent: :destroy
  has_many :products, through: :prices

  before_validation :assign_public_uuid, on: :create

  validates :public_uuid, presence: true, uniqueness: true

  private

  def assign_public_uuid
    self.public_uuid ||= SecureRandom.uuid
  end
end
