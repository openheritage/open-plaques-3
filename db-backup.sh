heroku pg:backups capture --app open-plaques-beta
curl -o db/db.dump `heroku pg:backups --app open-plaques-beta public-url`
createdb openplaques_20161026
pg_restore -d openplaques_20161026 db/db.dump
