xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.kml(:xmlns=>"http://www.opengis.net/kml/2.2","xmlns:atom"=>"http://www.w3.org/2005/Atom") do
  xml.Document do
    xml.name "OpenPlaques.org"
    xml.atom :link, "href"=>"http://openplaques.org"
    xml.description "Commemorative plaques around the world"

    xml.Style(:id=>"plaqueIcon") do
      xml.IconStyle do
        xml.Icon do
          xml.href "http://openplaques.org/images/openplaques-icon.png"
        end
      end
    end

    for role in @roles
      xml.Folder do
        xml.name role.name
        for person in role.people
          for plaque in person.plaques
          if plaque.geolocated?
            xml.Placemark do
              xml.name(plaque.title)
              xml.description(plaque.inscription + " " +plaque_url(plaque) + photo_img(plaque))
              if plaque.latitude && plaque.longitude
                xml.Point do
                  xml.coordinates plaque.longitude.to_s + ',' + plaque.latitude.to_s + ",0"
                end
              end
              xml.styleUrl "#plaqueIcon"
            end
          end
          end
        end
      end
    end
  end
end
