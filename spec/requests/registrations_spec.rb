# frozen_string_literal: true

RSpec.describe 'Registrations', type: :request do
  it 'creates an account for the signed up user' do
    expect do
      post '/users',
           params: { user: { name: 'name', email: 'email@email.com', password: '123456',
                             password_confirmation: '123456' } }
    end.to change { User.count }.by(1).and change { Account.count }.by(1)

    expect(response).to redirect_to('/')
  end
end
