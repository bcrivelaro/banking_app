RSpec.describe Account, type: :model do
  subject { build :account, user: create(:user), account_number: '123' }

  it { should belong_to(:user) }

  it { should validate_uniqueness_of(:user_id).case_insensitive }
  it { should validate_numericality_of(:balance_in_cents).is_greater_than_or_equal_to(0).only_integer }

  describe '#valid?' do
    context 'when record is not persisted (before_validation)' do
      it 'generates an account number' do
        account = build :account, account_number: nil

        expect { account.valid? }.to change { account.account_number.present? }.from(false).to(true)
      end

      context 'when account number already exists in database' do
        it 'generates an account number' do
          allow(Account).to receive_message_chain(:where, :exists?).and_return(true, false)
          account = build :account, account_number: nil

          expect { account.valid? }.to change { account.account_number.present? }.from(false).to(true)
        end
      end
    end

    context 'when record is persisted' do
      it 'adds errors on blank account number' do
        account = create :account
        account.account_number = nil

        expect(account.valid?).to eq(false)
        expect(account.errors[:account_number]).to eq(["can't be blank"])
      end

      context 'when account number already exists in database' do
        it 'adds errors on duplicated account number' do
          account_1 = create :account
          account_2 = create :account
          account_2.account_number = account_1.account_number

          expect(account_2.valid?).to eq(false)
          expect(account_2.errors[:account_number]).to eq(['has already been taken'])
        end
      end
    end
  end

  describe '#balance' do
    [
      { balance_in_cents: 100, expected_balance: 1 },
      { balance_in_cents: 1000, expected_balance: 10 },
      { balance_in_cents: 19148, expected_balance: 191.48 },
    ].each do |example|
      it 'returns the expected balance in dollars' do
        account = build :account, balance_in_cents: example[:balance_in_cents]

        expect(account.balance).to eq(example[:expected_balance])
      end
    end
  end
end
