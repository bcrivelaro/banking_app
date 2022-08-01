![example workflow](https://github.com/bcrivelaro/banking_app/actions/workflows/ci.yml/badge.svg)

# Setup

Regardless your approach to launch the application, get the env vars:

```bash
  $ cp .env.example .env
```

### Everything in Docker

```bash
  $ docker-compose build
  $ docker-compose up -d
  $ docker-compose run app rails db:create db:migrate
```

### Postgres in Docker, Rails bare metal

Change your `DB_HOST` env var to `localhost` and:

```bash
  $ docker-compose up -d db
  $ rails db:create db:migrate
  $ rails server
```

### Create user and deposit money

Open rails console and run the following:
```ruby
  user = User.create!(name: 'User', email: 'user@email.com', password: '123456', password_confirmation: '123456')
  account = Account.create!(user: user)
  DepositService.new(to_account: account, amount: 100).save
```

### Tests

```ruby
  bundle exec rspec
```

### Troubleshooting

Having problems with folder permissions when using Docker in Linux? Try running:

```bash
  $ sudo chown -R ${USER}:${USER} tmp/db
```

If the problem persists, try:

```bash
  $ sudo chown -R ${USER}:${USER} .
```
