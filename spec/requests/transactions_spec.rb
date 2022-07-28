# frozen_string_literal: true

RSpec.describe '/transactions', type: :request do
  let(:account) { create :account }
  let(:user) { account.user }

  context 'when user is not signed in' do
    it 'redirects to sign in' do
      get '/transactions'

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'when user is signed in' do
    before :each do
      sign_in(user)
    end

    context 'when user does not have transactions' do
      it 'renders a successful response' do
        get '/transactions'

        expect(response).to have_http_status(:ok)
        expect(response.body).to_not include('Transactions')
      end
    end

    context 'when user does have transactions' do
      it 'renders a successful response' do
        transaction = DepositService.new(to_account: account, amount: 199.99).save

        get '/transactions'

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Transactions')
        expect(response.body).to include('Deposit')
        expect(response.body).to include(transaction.amount.to_s)
      end
    end
  end
end
