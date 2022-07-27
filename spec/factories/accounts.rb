# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    user
    account_number { '123456789' }
    balance_in_cents { 10_000 }
  end
end
