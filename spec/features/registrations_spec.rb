# frozen_string_literal: true

RSpec.feature 'Registrations', type: :feature do
  scenario 'user sign up and account is created' do
    visit '/users/sign_up'
    fill_in 'Name', with: 'John'
    fill_in 'Email', with: 'john@email.com'
    fill_in 'Password', with: '123456'
    fill_in 'Password confirmation', with: '123456'

    expect do
      click_button('Sign up')
    end.to change { User.count }.by(1).and change { Account.count }.by(1)

    expect(page).to have_text('Welcome! You have signed up successfully.')
  end
end
