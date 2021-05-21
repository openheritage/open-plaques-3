country = Country.find_by_name('United Kingdom')
Dir.mkdir("/app/storage/#{country.to_param}") unless File.exists?("/app/storage/#{country.to_param}")
country.areas.each do |area|
  Dir.mkdir("/app/storage/#{country.to_param}/#{area.to_param}") unless File.exists?("/app/storage/#{country.to_param}/#{area.to_param}")
  area.plaques.ungeolocated.find_in_batches do |group|
    group.each do |plaque|
      #unless plaque.geolocated?
#        File.write("/app/storage/#{country.to_param}/#{area.to_param}/#{plaque.to_param}.json", plaque.to_json)
        File.write("/app/storage/#{country.to_param}/#{area.to_param}/#{plaque.to_param}.csv", PlaqueCsv.new([plaque]).build)
      #end
    end
  end
end
