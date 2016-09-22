require 'CSV'
require 'uri'
require 'net/http'
require 'json'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

CSV.foreach('hit.csv', headers: true) do |csv_obj|
  uri_string = 'http://0.0.0.0:3000' + csv_obj['Page'].to_s + '.json'
#  puts uri_string
  uri = URI.parse(uri_string)
  req = Net::HTTP::Get.new(uri.path)
  http = Net::HTTP.new(uri.host, uri.port)
  response = http.start {|htt| htt.request(req)}

  json = JSON.parse(response.body)
#  if 'Ireland' == json['properties']['location']['area']['country']['name']
    puts $.
    puts ' http://openplaques.org/plaques/' + json['properties']['id'].to_s + ' "' + json['properties']['inscription']
#  end
end
