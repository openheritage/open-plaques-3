country = Country.find_by(name: 'United Kingdom')
Dir.mkdir("/app/storage/#{country.to_param}") unless File.exist?("/app/storage/#{country.to_param}")
country.areas.each do |area|
  Dir.mkdir("/app/storage/#{country.to_param}/#{area.to_param}") unless File.exist?("/app/storage/#{country.to_param}/#{area.to_param}")
  area.plaques.find_in_batches do |group|
    group.each do |plaque|
      # File.write("/app/storage/#{country.to_param}/#{area.to_param}/#{plaque.to_param}.geojson", plaque.to_geojson) if plaque.geolocated?
      File.write("/app/storage/#{country.to_param}/#{area.to_param}/#{plaque.to_param}.json", plaque.to_json)
      # File.write("/app/storage/#{country.to_param}/#{area.to_param}/#{plaque.to_param}.csv", PlaqueCsv.new([plaque]).build)
    end
  end
end
