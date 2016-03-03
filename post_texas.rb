require 'uri'
require 'net/http'
require 'json'

require 'CSV'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'UTMFormat'
require 'UTMToLatLng'
 
def post_to_endpoint(endpoint,inscription,location,area,latitude,longitude)
  uri = URI.parse(endpoint)
 
  post_params = { 
    :location => location,
    :area => area,
    :plaque => {
      :inscription => inscription, 
      :inscription_is_stub => "0",
      :language_id => "1", 
      :country => "13", 
      :longitude => longitude,
      :latitude => latitude,
      :series_id => 35,
      :colour_id => 3
    },
    :organisation_name => "Texas Historical Commission"
  }
 
  # Convert the parameters into JSON and set the content type as application/json
  req = Net::HTTP::Post.new(uri.path)
  req.body = JSON.generate(post_params)
  req["Content-Type"] = "application/json"
  
  http = Net::HTTP.new(uri.host, uri.port)
  response = http.start {|htt| htt.request(req)}
  
  puts response
end

format = UTMFormat.factory(:nad27)

# filename = 'Cemetery_20160227_053514_473875.csv'
filename = ''

CSV.foreach(filename, :headers => true) do |csv_obj|
  inscription = csv_obj['title'].to_s + '. ' + csv_obj['markertext'].to_s + ' #'+ csv_obj['markernum']
  location =  csv_obj['address'].to_s
  city =  csv_obj['city'].to_s + ", TX"
  utm_zone = csv_obj['utm_zone'].to_f
  utm_east = csv_obj['utm_east'].to_f
  utm_north = csv_obj['utm_north'].to_f
  latlng = UTMtoLatLng.new(utm_zone, false, utm_east, utm_north, format)
  test = "http://0.0.0.0:3001/plaques"
  live = "http://openplaques.org/plaques"
  post_to_endpoint(test, inscription, location, city, latlng.lat, latlng.lng)
end
