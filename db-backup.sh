# heroku pg:backups capture --app open-plaques-beta
# curl -o db/db.dump `heroku pg:backups --app open-plaques-beta public-url`
# createdb openplaques_$(date +'%Y-%m-%d')
# pg_restore -d openplaques_$(date +'%Y-%m-%d') db/db.dump
sed -iE "s/openplaques_[0-9|-]*/openplaques_$(date +'%Y-%m-%d')/g" config/database.yml
