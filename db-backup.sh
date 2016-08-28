heroku pg:backups capture --app open-plaques-beta
curl -o db/db.dump `heroku pg:backups --app open-plaques-beta public-url`
pg_restore -d openplaques_20160611 db/db.dump
