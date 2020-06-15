heroku pg:backups capture --app open-plaques-beta
rm openplaques_production.dump
curl -o openplaques_production.dump `heroku pg:backups --app open-plaques-beta public-url`
dropdb -h postgres -U postgres openplaques_development
createdb -h postgres -U postgres openplaques_development
pg_restore -h postgres -U postgres -d openplaques_development openplaques_production.dump
createdb -h postgres -U postgres openplaques_test
