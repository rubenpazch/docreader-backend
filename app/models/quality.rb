class Quality < ApplicationRecord
  has_many :prices, dependent: :destroy
end
