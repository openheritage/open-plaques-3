module ActiveRecordExtensions
 
  def as_geojsonzz(options = nil) #:nodoc:
    to_a.as_geojson(options)
  end

end
 
# And now extend the ActiveRecord::Base that all our classes inherit so we have this method everywhere
ActiveRecord::Relation.extend ActiveRecordExtensions