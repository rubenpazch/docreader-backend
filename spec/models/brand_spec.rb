require 'rails_helper'

RSpec.describe Brand, type: :model do
  it { should have_many(:prices).dependent(:destroy) }
  it { should have_many(:products).through(:prices) }
end
