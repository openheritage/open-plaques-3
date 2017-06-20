curl http://0.0.0.0:3000/places/gb/areas/london/plaques.csv > db/open-plaques-london-2017-06-19.csv
curl http://0.0.0.0:3000/places/gb/plaques.csv > db/open-plaques-United-Kingdom-2017-06-19.csv
curl http://0.0.0.0:3000/plaques.csv > db/open-plaques-all-2017-06-19.csv

curl http://0.0.0.0:3000/places/gb/areas/london/plaques.json > db/open-plaques-london-2017-06-19.json
curl http://0.0.0.0:3000/places/gb/plaques.json > db/open-plaques-United-Kingdom-2017-06-19.json
curl http://0.0.0.0:3000/plaques.json > db/open-plaques-all-2017-06-19.json

curl http://0.0.0.0:3000/places/gb/areas/london/plaques.geojson > db/open-plaques-london-2017-06-19.geojson
curl http://0.0.0.0:3000/places/gb/plaques.geojson > db/open-plaques-United-Kingdom-2017-06-19.geojson
curl http://0.0.0.0:3000/plaques.json > db/open-plaques-all-2017-06-19.geojson
