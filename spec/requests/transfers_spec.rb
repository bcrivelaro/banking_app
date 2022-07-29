# frozen_string_literal: true

RSpec.describe '/transfers', type: :request do
  let(:account) { create :account }
  let(:user) { account.user }
  let(:to_account) { create :account }

  context 'when user is not signed in' do
    it 'redirects to sign in' do
      get '/transfers/new'

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'when user is signed in' do
    before :each do
      sign_in(user)
    end

    describe 'GET /transfers/new' do
      it 'renders a successful response' do
        get '/transfers/new'

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('New transfer')
      end
    end

    describe 'POST /transfers' do
      context 'when params are invalid' do
        it 'renders page with errors' do
          post '/transfers', params: { amount: 20, to_account_number: '9999999999' }

          expect(response).to have_http_status(:ok)
          expect(response.body).to include('To account number account not found with given account number')
        end

        it 'does not create Transaction' do
          expect do
            post '/transfers', params: { amount: 20, to_account_number: to_account.account_number }
          end.to_not change { Transaction.count }
        end

        it 'does not change from account balance' do
          expect do
            post '/transfers', params: { amount: 20, to_account_number: to_account.account_number }
          end.to_not change { account.reload.balance }
        end

        it 'does not change to account balance' do
          expect do
            post '/transfers', params: { amount: 20, to_account_number: to_account.account_number }
          end.to_not change { to_account.reload.balance }
        end
      end

      context 'when params are valid' do
        let(:account) { create :account, with_deposit: 99_999 }

        it 'redirects to transactions page' do
          post '/transfers', params: { amount: 20, to_account_number: to_account.account_number }

          expect(response).to redirect_to('/transactions')
        end

        it 'does create Transaction for both accounts' do
          expect do
            post '/transfers', params: { amount: 20, to_account_number: to_account.account_number }
          end.to(
            change { account.transactions.count }.by(1).and(
              change do
                to_account.transactions.count
              end.by(1)
            )
          )
        end

        it 'does create Transaction for to_account' do
          expect do
            post '/transfers', params: { amount: 20, to_account_number: to_account.account_number }
          end
        end

        it 'does change from account balance' do
          expect do
            post '/transfers', params: { amount: 20, to_account_number: to_account.account_number }
          end.to change { account.reload.balance }.from(99_999).to(99_979)
        end

        it 'does change to account balance' do
          expect do
            post '/transfers', params: { amount: 20, to_account_number: to_account.account_number }
          end.to change { to_account.reload.balance }.from(0).to(20)
        end
      end
    end
  end
end
