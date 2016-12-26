## Start project

```
docker-compose up
```

App is now available on http://localhost:3000

## Start project in the foreground (ie. for `pry`)

```
docker-compose run --service-ports web
```

The the code will correctly stop on `binding.pry`

## Rake task execution

Example of database seeding

```
docker-compose run web bundle exec rake db:seed
```

## Dependencies

### Install/update node dependency

```
docker-compose run web npm install <package> --save
```

### Install/update ruby dependency

Edit your Gemfile

```
docker-compose run web bundle install
```

## Connect to mongodb instance

```
docker-compose exec mongo mongo 'mongodb://admin:admin-secret@mongo:27017/viaticus-development?authSource=admin'
```
