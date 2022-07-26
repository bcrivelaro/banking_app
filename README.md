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
```

### Troubleshooting

Having problems with folder permissions when using Docker in Linux? Try running:

```bash
  $ sudo chown -R ${USER}:${USER} tmp/db
```
