xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
    @plaques.each do |plaque|

      xml.plaque(uri: plaque.uri, machine_tag: plaque.machine_tag, created_at: plaque.created_at.xmlschema, updated_at: plaque.updated_at.xmlschema){
        xml.title plaque.title
        xml.subjects plaque.subjects
        if plaque.colour
          xml.colour plaque.colour_name
        end
        xml.inscription {
          xml.raw plaque.inscription
          xml.linked linked_inscription(plaque) if linked_inscription(plaque) != plaque.inscription
        }
        if plaque.geolocated?
          xml.geo(reference_system: "WGS84", latitude: plaque.latitude, longitude: plaque.longitude, is_accurate: plaque.is_accurate_geolocation)
        end
        xml.location {
          xml.address plaque.address
          if plaque.area
            xml.locality(uri: area_url(plaque.area)) {
              xml.text! plaque.area.name
            }
          end
          if plaque.area.country
            xml.country(uri: country_url(plaque.area.country)) {
              xml.text! plaque.area.country.name
            }
          end
        }
        plaque.organisations.each do |organisation|
          xml.organisation(uri: organisation_url(organisation)) {
            xml.text! organisation.name
          }
        end
        if plaque.erected_at?
          if plaque.erected_at.day == 1 && plaque.erected_at.day == 1
            xml.date_erected plaque.erected_at.year
          else
            xml.date_erected plaque.erected_at
          end
        end
        plaque.people.each do |person|
          xml.person(uri: person_url(person)) {
    	      xml.text! person.name
    	    }
        end
        plaque.photos.each do |photo|
          xml.photo(uri: photo_url(photo.id)) {
            xml.webpage(uri: photo.url)
            xml.fullsize(uri: photo.file_url)
            xml.thumbnail(uri: photo.thumbnail_url)
            xml.photographer(uri: photo.photographer_url) {
              begin
                xml.text! photo.photographer
              rescue
                xml.text! 'unknown'
              end
            }
            if photo.shot_name
              xml.shot(order: photo.shot_order) {
                xml.text! photo.shot_name
              }
            end
            if photo.licence
              xml.licence(uri: photo.licence.url) {
                xml.text! photo.licence.name
              }
            end
            xml.plaque(uri: plaque_url(photo.plaque)) if photo.plaque
          }
        end
      }

    end
}
