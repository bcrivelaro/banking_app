RSpec.feature "Transactions", :type => :feature do
  let(:user) { create :user, password: '123456', password_confirmation: '123456' }
  let(:account) { create :account, user: user }

  context 'when user is not signed in' do
    scenario 'redirects to sign in' do
      visit '/transactions'

      expect(current_path).to eq('/users/sign_in')
    end
  end

  context 'when user is signed in' do
    scenario 'renders page successfully' do
      transaction = DepositService.new(to_account: account, amount: 199.99).save

      visit '/'
      fill_in 'Email', with: user.email
      fill_in 'Password', with: '123456'
      click_button('Log in')

      visit '/transactions'

      expect(page).to have_text("Hi #{user.name}")
      expect(page).to have_text("Your balance is $ #{account.reload.balance}")
      expect(page).to have_button('Transfer money')
      expect(page).to have_text('Transactions')
      expect(page).to have_text('Deposit')
      expect(page).to have_text("$ #{transaction.amount.to_s}")
      expect(page).to have_button('Logout')
    end
  end
end
