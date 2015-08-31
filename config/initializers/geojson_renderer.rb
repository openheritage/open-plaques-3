Mime::Type.register 'application/json', :geojson
ActionController::Renderers.add :geojson do |object, options|
  puts '*** geojson renderer'
  geojson = ''
  begin
    begin
      geojson = object.as_geojson(options).to_json
      puts '*** basic as_geojson.to_json'
    rescue
      if object.longitude
        {
          type: 'Feature',
          geometry: 
          {
            type: 'Point',
            coordinates: [object.longitude, object.latitude]
          },
          properties: object.as_json(options)
        }.to_json
      else
        {
          type: 'Feature',
          geometry: 
          {
            type: 'Point',
            coordinates: [0, 0]
          },
          properties: object.as_json(options)
        }.to_json
      end
    end
  rescue
  	geojson  = '{'
    geojson += '  "type": "FeatureCollection",'
    geojson += '  "features": ['
	  object.each_with_index do |o, index|
	    geojson += o.as_geojson.to_json
	    geojson += "," if index != object.size-1
	  end
    geojson += '  ]'
#    if (options(:parent))
#      {
#    geojson += ',  "properties": ' + object.as_json(options)
#  }
    geojson += '}'
  end
  self.content_type ||= Mime::JSON
  geojson
end