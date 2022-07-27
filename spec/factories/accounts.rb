FactoryBot.define do
  factory :account do
    user
    account_number { "123456789" }
    balance_in_cents { 10000 }
  end
end
