# frozen_string_literal: true

RSpec.feature 'Transfers', type: :feature do
  let(:user) { create :user, password: '123456', password_confirmation: '123456' }
  let!(:account) { create :account, user:, with_deposit: 1000 }
  let(:to_account) { create :account }

  context 'when user is not signed in' do
    scenario 'redirects to sign in' do
      visit '/transfers/new'

      expect(current_path).to eq('/users/sign_in')
    end
  end

  context 'when user is signed in' do
    context 'when params are invalid' do
      scenario 'does not create transfer' do
        visit '/'
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '123456'
        click_button('Log in')

        visit '/transfers/new'

        expect(page).to have_text('New transfer')
        fill_in 'To account number', with: to_account.account_number
        fill_in 'Amount', with: 9999999999

        click_button('Transfer')

        expect(account.transactions.count).to eq(1)
        expect(account.balance).to eq(1000)
        expect(to_account.transactions.count).to eq(0)
        expect(to_account.balance).to eq(0)

        expect(current_path).to eq('/transfers')
        expect(page).to have_text('From account account does not have sufficient funds')
      end
    end

    context 'when params are valid' do
      scenario 'creates transfer successfully' do
        visit '/'
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '123456'
        click_button('Log in')

        visit '/transfers/new'

        expect(page).to have_text('New transfer')
        fill_in 'To account number', with: to_account.account_number
        fill_in 'Amount', with: 10.15
        expect do
          click_button('Transfer')
        end.to(
          change do
            account.transactions.count
          end.by(1).and(
            change do
              to_account.transactions.count
            end.by(1)
          ).and(
            change do
              account.reload.balance
            end.from(1000).to(989.85).and(
              change do
                to_account.reload.balance
              end.from(0).to(10.15)
            )
          )
        )

        expect(current_path).to eq('/transactions')
        expect(page).to have_text('Transfer successfully created!')
      end
    end
  end
end
