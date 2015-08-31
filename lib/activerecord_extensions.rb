module ActiveRecordExtensions extend ActiveSupport::Concern

  def as_geojson(options = nil) #:nodoc:
    # do the equivalent to Array.as_json(options)
    puts '*** options ' + options.to_s
 #   if options[:parent]
      { 
        type: 'FeatureCollection',
        properties: options[:parent] ? options[:parent] : {}, 
        features: map { |v| options ? v.as_geojson(options.dup) : v.as_geojson }
      }
#    else
#      { 
#        type: 'FeatureCollection',
#        features: map { |v| options ? v.as_geojson(options.dup) : v.as_geojson }
#      }
#    end
  end

end
 
ActiveRecord::Relation.send(:include, ActiveRecordExtensions)