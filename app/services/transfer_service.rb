# frozen_string_literal: true

class TransferService
  include ActiveModel::Validations

  validates :from_account, presence: true
  validates :to_account_number, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :to_account_exists
  validate :from_account_has_sufficient_balance

  def initialize(from_account:, to_account_number:, amount:)
    @from_account = from_account
    @to_account_number = to_account_number
    @amount = amount
  end

  def save
    return unless valid?

    ActiveRecord::Base.transaction do
      update_from_account_balance!
      update_to_account_balance!
      create_transaction!
    end
  end

  private

  attr_reader :from_account, :to_account_number, :to_account, :amount

  def to_account_exists
    return if to_account_number.blank?

    @to_account = Account.find_by(account_number: to_account_number)
    return if to_account.present?

    errors.add(:to_account_number, :account_not_found)
  end

  def from_account_has_sufficient_balance
    return if from_account.blank?
    return unless amount.is_a?(Numeric)
    return if from_account.balance >= amount

    errors.add(:from_account, :non_sufficient_funds)
  end

  def amount_in_cents
    @amount_in_cents ||= amount * 100
  end

  def create_transaction!
    Transaction.create!(transaction_type: :transfer,
                        from_account:,
                        to_account:,
                        amount_in_cents:)
  end

  def update_from_account_balance!
    from_account.update!(balance_in_cents: from_account.balance_in_cents - amount_in_cents)
  end

  def update_to_account_balance!
    to_account.update!(balance_in_cents: to_account.balance_in_cents + amount_in_cents)
  end
end
