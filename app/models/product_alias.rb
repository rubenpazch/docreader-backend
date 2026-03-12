class ProductAlias < ApplicationRecord
  belongs_to :product

  before_validation :assign_public_uuid, on: :create

  validates :name, presence: true, uniqueness: true
  validates :public_uuid, presence: true, uniqueness: true

  private

  def assign_public_uuid
    self.public_uuid ||= SecureRandom.uuid
  end
end
