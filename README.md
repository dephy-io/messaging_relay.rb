# README

## Requirements

- Ruby 3.3.0
- PostgreSQL

## Prepare

```
bundle
cp config/database.yml.example config/database.yml
cp config/cable.yml.example config/cable.yml
EDITOR=cat bin/rails credentials:edit
rails db:create
rails db:migrate
```

## Run

```
rails s
```

## DB Benchmark

```
RAILS_ENV=production bundle exec rake benchmark:bm NUM=500
# batch create
RAILS_ENV=production bundle exec rake benchmark:bm NUM=5000 BATCH=100
```

## License

Apache 2.0
