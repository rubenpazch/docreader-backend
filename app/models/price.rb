class Price < ApplicationRecord
  belongs_to :product
  belongs_to :brand
  belongs_to :quality

  before_validation :assign_public_uuid, on: :create

  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :public_uuid, presence: true, uniqueness: true

  private

  def assign_public_uuid
    self.public_uuid ||= SecureRandom.uuid
  end
end
