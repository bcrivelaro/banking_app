class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, ->(acc) { unscope(:where).where(from_account: acc).or(where(to_account: acc)) }

  validates :user_id, uniqueness: { case_sensitive: false }
  validates :account_number, presence: true, uniqueness: { case_sensitive: false }
  validates :balance_in_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :generate_account_number, on: :create

  def balance
    BigDecimal((balance_in_cents / 100.00).to_s)
  end

  private

  def generate_account_number
    return if persisted?

    loop do
      self.account_number = rand.to_s[2..9]

      break unless Account.where(account_number: self.account_number).exists?
    end
  end
end
