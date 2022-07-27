# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum transaction_type: { deposit: 'deposit', transfer: 'transfer' }

  belongs_to :from_account, class_name: 'Account', optional: true
  belongs_to :to_account, class_name: 'Account'

  validates :amount_in_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :from_account_id, presence: true, if: -> { transfer? }

  def amount
    BigDecimal((amount_in_cents / 100.00).to_s)
  end
end
