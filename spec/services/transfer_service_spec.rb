# frozen_string_literal: true

RSpec.describe TransferService do
  subject(:service) { described_class.new(**attributes) }
  let(:from_account) { create :account }
  let(:to_account) { create :account }
  let(:to_account_number) { to_account.account_number }
  let(:amount) { 25 }
  let(:attributes) { { from_account:, to_account_number:, amount: } }

  describe '#valid?' do
    context 'when missing from_account' do
      let(:from_account) { nil }

      it do
        expect(service.valid?).to eq(false)
        expect(service.errors[:from_account]).to eq(["can't be blank"])
      end
    end

    context 'when missing to_account_number' do
      let(:to_account_number) { nil }

      it do
        expect(service.valid?).to eq(false)
        expect(service.errors[:to_account_number]).to eq(["can't be blank"])
      end
    end

    context 'when there is no account with given to_account_number' do
      let(:to_account_number) { '9999999999999999' }

      it do
        expect(service.valid?).to eq(false)
        expect(service.errors[:to_account_number]).to(
          eq(['account not found with given account number'])
        )
      end
    end

    context 'when missing amount' do
      let(:amount) { nil }

      it do
        expect(service.valid?).to eq(false)
        expect(service.errors[:amount]).to eq(["can't be blank", 'is not a number'])
      end
    end

    context 'when amount is not a number' do
      let(:amount) { 'foobar' }

      it do
        expect(service.valid?).to eq(false)
        expect(service.errors[:amount]).to eq(['is not a number'])
      end
    end

    context 'when amount is not greater than 0' do
      let(:amount) { 0 }

      it do
        expect(service.valid?).to eq(false)
        expect(service.errors[:amount]).to eq(['must be greater than 0'])
      end
    end

    context 'when to account number is the same from_account' do
      let(:to_account_number) { from_account.account_number }

      it do
        expect(service.valid?).to eq(false)
        expect(service.errors[:to_account_number]).to eq(['cannot transfer to same account'])
      end
    end

    context 'when from account does not have sufficient funds' do
      it do
        expect(from_account.balance).to eq(0)
        expect(service.valid?).to eq(false)
        expect(service.errors[:from_account]).to eq(['account does not have sufficient funds'])
      end
    end

    context 'when all attributes are valid' do
      let(:from_account) { create :account, with_deposit: 100 }

      it do
        expect(from_account.balance).to eq(100)
        expect(service.valid?).to eq(true)
      end
    end

    context 'when amount is valid string' do
      let(:from_account) { create :account, with_deposit: 100 }
      let(:amount) { '11.12' }

      it { expect(service.valid?).to eq(true) }
    end
  end

  describe '#save' do
    context 'when not valid' do
      let(:amount) { nil }

      it 'does nothing' do
        expect(ActiveRecord::Base).to_not receive(:transaction)

        service.save
      end
    end

    context 'when valid' do
      let(:from_account) { create :account, with_deposit: 300 }
      let(:to_account) { create :account, with_deposit: 100 }

      it 'returns the created transaction' do
        expect(service.save).to be_a(Transaction)
      end

      it 'creates a transaction for both accounts' do
        expect { service.save }.to(
          change { from_account.transactions.count }.by(1)
            .and(change do
                   to_account.transactions.count
                 end.by(1))
        )
      end

      it 'changes both accounts balances' do
        expect { service.save }.to(
          change { from_account.reload.balance }.from(300).to(275)
            .and(change do
                   to_account.reload.balance
                 end.from(100).to(125))
        )
      end
    end

    context 'when some database error occours' do
      let(:from_account) { create :account, with_deposit: 300 }
      let(:to_account) { create :account, with_deposit: 100 }

      before :each do
        # First call 'attributes' to avoid mocking Transaction.create!
        # when creating 'from_account' and 'to_account' above because they
        # call Transaction.create!
        attributes
        expect(Transaction).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'raises an exception' do
        expect { service.save }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not remove money from from_account' do
        expect do
          service.save
        rescue ActiveRecord::RecordInvalid
        end.to_not change { from_account.reload.balance }
      end

      it 'does not add money to to_account' do
        expect do
          service.save
        rescue ActiveRecord::RecordInvalid
        end.to_not change { to_account.reload.balance }
      end

      it 'does not create a transaction' do
        expect do
          service.save
        rescue ActiveRecord::RecordInvalid
        end.to_not change { Transaction.count }
      end
    end
  end
end
