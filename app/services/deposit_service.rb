# frozen_string_literal: true

class DepositService
  include ActiveModel::Validations

  validates :to_account, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :valid_amount

  def initialize(to_account:, amount:)
    @to_account = to_account
    @amount = amount
  end

  def save
    return unless valid?

    ActiveRecord::Base.transaction do
      update_to_account_balance!
      create_transaction!
    end
  end

  private

  attr_reader :to_account, :amount

  def valid_amount
    return if amount.blank?
    return if errors[:amount].present?
    return unless amount.is_a?(String)

    @amount = BigDecimal(amount)
  end

  def amount_in_cents
    @amount_in_cents ||= (amount * 100).to_i
  end

  def create_transaction!
    Transaction.create!(transaction_type: :deposit,
                        from_account: nil,
                        to_account:,
                        amount_in_cents:)
  end

  def update_to_account_balance!
    to_account.update!(balance_in_cents: to_account.balance_in_cents + amount_in_cents)
  end
end
