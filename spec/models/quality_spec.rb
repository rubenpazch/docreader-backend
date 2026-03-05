require 'rails_helper'

RSpec.describe Quality, type: :model do
  it { should have_many(:prices).dependent(:destroy) }
end
