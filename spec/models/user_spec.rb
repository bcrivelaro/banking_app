# frozen_string_literal: true

RSpec.describe User, type: :model do
  it { should have_one(:account) }

  it { should validate_presence_of(:name) }
end
