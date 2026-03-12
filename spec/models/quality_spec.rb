require 'rails_helper'

RSpec.describe Quality, type: :model do
  it { should have_many(:prices).dependent(:destroy) }

  it 'asigna public_uuid al crear' do
    quality = create(:quality)

    expect(quality.public_uuid).to match(/\A[0-9a-f\-]{36}\z/)
  end
end
