# README

## Requirements

- Ruby 3.4.1
- PostgreSQL

## Prepare

```
bin/setup --skip-server
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
