require 'rails_helper'

RSpec.describe Brand, type: :model do
  it { should have_many(:prices).dependent(:destroy) }
  it { should have_many(:products).through(:prices) }

  it 'asigna public_uuid al crear' do
    brand = create(:brand)

    expect(brand.public_uuid).to match(/\A[0-9a-f\-]{36}\z/)
  end
end
