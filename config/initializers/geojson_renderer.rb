ActionController::Renderers.add :geojson do |object, options|
  self.content_type ||= Mime::JSON
  '{}'
  if object.respond_to? :as_geojson
    # object has deliberately overridden as_geojson(options)
    object.as_geojson(options).to_json
  elsif object.respond_to? :longitude
    {
      type: 'Feature',
      geometry:
      {
        type: 'Point',
        coordinates: [object.longitude, object.latitude]
      },
      properties: object.as_json(options)
    }.to_json
  elsif object.respond_to? :each_with_index
    geojson  = '{'
    geojson += '  "type": "FeatureCollection",'
    geojson += '  "features": ['
    object.each_with_index do |o, index|
      if object.respond_to? :as_geojson
        # object has deliberately overridden as_geojson(options)
        geojson += object.as_geojson(options).to_json
      elsif object.respond_to? :longitude
        geojson += {
          type: 'Feature',
          geometry:
          {
            type: 'Point',
            coordinates: [object.longitude, object.latitude]
          },
          properties: object.as_json(options)
        }.to_json
      end
      geojson += "," if index != object.size-1
    end
    geojson += '  ]'
    geojson += '}'
    geojson
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
