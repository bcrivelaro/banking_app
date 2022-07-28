# frozen_string_literal: true

RSpec.describe DepositService do
  subject(:service) { described_class.new(**attributes) }
  let(:to_account) { create :account }
  let(:amount) { 35 }
  let(:attributes) { { to_account:, amount: } }

  describe '#valid?' do
    context 'when missing to_account' do
      let(:to_account) { nil }

      it do
        expect(service.valid?).to eq(false)
        expect(service.errors[:to_account]).to eq(["can't be blank"])
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

    context 'when all attributes are valid' do
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
      let(:to_account) { create :account, with_deposit: 300 }

      it 'returns the created transaction' do
        expect(service.save).to be_a(Transaction)
      end

      it 'creates a transaction for the account' do
        expect { service.save }.to change { to_account.transactions.count }.by(1)
      end

      it 'changes the account balance' do
        expect { service.save }.to change { to_account.reload.balance }.from(300).to(335)
      end
    end

    context 'when some database error occours' do
      let(:to_account) { create :account, with_deposit: 300 }

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
