FactoryBot.define do
  factory :transaction do
    transaction_type { :transfer }
    from_account { association :account }
    to_account { association :account }
    amount_in_cents { 100 }
  end
end
