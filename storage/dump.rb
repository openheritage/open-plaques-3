country = Country.find_by_name('United Kingdom')
Dir.mkdir("/app/storage/#{country.name.downcase}") unless File.exists?("/app/storage/#{country.name.downcase}")
country.areas.each do |area|
  Dir.mkdir("/app/storage/#{country.name.downcase}/#{area.to_param}") unless File.exists?("/app/storage/#{country.name.downcase}/#{area.to_param}")
  area.plaques.find_in_batches do |group|
    group.each do |plaque|
      if plaque.geolocated?
        File.write("/app/storage/#{country.name.downcase}/#{area.to_param}/#{plaque.to_param}.json", plaque.to_json)
      end
    end
  end
end