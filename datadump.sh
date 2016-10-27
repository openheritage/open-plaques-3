rm ~/Dropbox/Public/openplaques/open-plaques-london-2016-05-22.csv
curl http://0.0.0.0:3000/places/gb/areas/london/plaques.csv > ~/Dropbox/Public/openplaques/open-plaques-london-2016-10-26.csv
rm ~/Dropbox/Public/openplaques/open-plaques-United-Kingdom-2016-05-22.csv
curl http://0.0.0.0:3000/places/gb/plaques.csv > ~/Dropbox/Public/openplaques/open-plaques-United-Kingdom-2016-10-26.csv
rm ~/Dropbox/Public/openplaques/open-plaques-all-2016-05-22.csv
curl http://0.0.0.0:3000/plaques.csv > ~/Dropbox/Public/openplaques/open-plaques-all-2016-10-26.csv

rm ~/Dropbox/Public/openplaques/open-plaques-london-2016-05-22.json
curl http://0.0.0.0:3000/places/gb/areas/london/plaques.json > ~/Dropbox/Public/openplaques/open-plaques-london-2016-10-26.json
rm ~/Dropbox/Public/openplaques/open-plaques-United-Kingdom-2016-05-22.json
curl http://0.0.0.0:3000/places/gb/plaques.json > ~/Dropbox/Public/openplaques/open-plaques-United-Kingdom-2016-10-26.json
rm ~/Dropbox/Public/openplaques/open-plaques-all-2016-05-22.json
curl http://0.0.0.0:3000/plaques.json > ~/Dropbox/Public/openplaques/open-plaques-all-2016-10-26.json
