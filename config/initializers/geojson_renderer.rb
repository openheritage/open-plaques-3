Mime::Type.register 'application/json', :geojson
ActionController::Renderers.add :geojson do |object, options|
  geojson = ''
  begin
    begin
      geojson = object.as_geojson.to_json
    rescue
      puts "object doesn't have as_geojson defined"
      if object.longitude
        puts "object doesn't have a geolocation"
        {
          type: 'Feature',
          geometry: 
          {
            type: 'Point',
            coordinates: [object.longitude, object.latitude]
          },
          properties:
            object.as_json(options)
        }.to_json
      else
        {
          type: 'Feature',
          geometry: 
          {
            type: 'Point',
            coordinates: [0, 0]
          },
          properties:
            object.as_json(options)
        }.to_json
      end
    end
  rescue
  	geojson = '{ "type": "FeatureCollection"'
#    geojson += ', "properties": {'
#    geojson += '}'
    geojson += ', "features": ['
	  object.each_with_index do |org, index| 
	    geojson += org.as_geojson.to_json 
	    geojson += "," if index != object.size-1
	  end
    geojson += ']'
    geojson += '}'
  end
  self.content_type ||= Mime::JSON
  geojson
end