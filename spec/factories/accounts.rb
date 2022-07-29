# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    user
    account_number { '123456789' }
    balance_in_cents { 0 }
    transient do
      with_deposit { nil }
    end

    after(:create) do |account, evaluator|
      if evaluator.with_deposit.present? && evaluator.with_deposit > 0
        DepositService.new(to_account: account, amount: evaluator.with_deposit).save
      end
    end
  end
end
