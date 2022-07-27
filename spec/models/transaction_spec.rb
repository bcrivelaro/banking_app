# frozen_string_literal: true

RSpec.describe Transaction, type: :model do
  it do
    should define_enum_for(:transaction_type)
      .with_values(deposit: 'deposit', transfer: 'transfer')
      .backed_by_column_of_type(:string)
  end
  it {
    should belong_to(:from_account).class_name('Account').optional
  }
  it { should belong_to(:to_account).class_name('Account') }
  it {
    should validate_numericality_of(:amount_in_cents).is_greater_than_or_equal_to(0).only_integer
  }

  describe '#valid?' do
    context 'when transaction_type is deposit' do
      it 'does not validate from_account presence' do
        account = create :account
        transaction = build :transaction, transaction_type: :deposit,
                                          from_account: nil,
                                          to_account: account

        expect(transaction.valid?).to eq(true)
      end
    end

    context 'when transaction_type is transfer' do
      it 'validates from_account presence' do
        account = create :account
        transaction = build :transaction, transaction_type: :transfer,
                                          from_account: nil,
                                          to_account: account

        expect(transaction.valid?).to eq(false)
        expect(transaction.errors[:from_account_id]).to eq(["can't be blank"])
      end
    end
  end

  describe '#amount' do
    [
      { amount_in_cents: 100, expected_amount: 1 },
      { amount_in_cents: 1000, expected_amount: 10 },
      { amount_in_cents: 19_148, expected_amount: 191.48 }
    ].each do |example|
      it 'returns the expected amount in dollars' do
        account = build :transaction, amount_in_cents: example[:amount_in_cents]

        expect(account.amount).to eq(example[:expected_amount])
      end
    end
  end
end
