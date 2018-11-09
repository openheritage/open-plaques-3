ActionController::Renderers.add :geojson do |object, options|
  self.content_type ||= Mime[:json]
  '{}'
  if object.respond_to? :each_with_index
    # is a set if things
    geojson = '{'
    geojson += '"type": "FeatureCollection",'
    geojson += '"features": ['
    object.each_with_index do |o, index|
      if o.respond_to?(:as_geojson) && (o.longitude != nil)
        # object defines its own as_geojson(options) method
        geojson += o.as_geojson(options).to_json
        geojson += ","
      elsif o.respond_to?(:longitude) &&
        o.respond_to?(:latitude) &&
        o.longitude != nil &&
        o.latitude != 51.475
        geojson += {
          type: 'Feature',
          geometry:
          {
            type: 'Point',
            coordinates: [o.longitude, o.latitude]
          },
          properties: o.as_json(options)
        }.to_json
        geojson += ","
      end
    end
    geojson = geojson.chomp(',')
    geojson += ']}'
    geojson
  elsif object.respond_to? :as_geojson
    # object defines its own as_geojson(options) method
    object.as_geojson(options).to_json
  elsif object.respond_to?(:longitude) &&
    object.respond_to?(:latitude) &&
    object.longitude != nil &&
    object.latitude != 51.475
    {
      type: 'Feature',
      geometry:
      {
        type: 'Point',
        coordinates: [object.longitude, object.latitude]
      },
      properties: object.as_json(options)
    }.to_json
  end
end
