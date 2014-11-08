xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.kml(:xmlns=>"http://www.opengis.net/kml/2.2","xmlns:atom"=>"http://www.w3.org/2005/Atom") do
  xml.Document do
    xml.name "OpenPlaques.org"
    xml.atom :link, "href"=>"http://openplaques.org"
    xml.description "Commemorative plaques around the world"

    ["blue", "black", "green","red","white","yellow"].each do |colour|
      xml.Style(:id=>"plaque-" + colour) do
        xml.IconStyle do
          xml.scale "0.5"
          xml.Icon do
            xml.href "http://openplaques.org/" + "assets/icon-" + colour + ".png"
          end
        end
      end

    end

    for plaque in @plaques
      kml(plaque, xml).to_s.gsub!("http://0.0.0.0:3000","http://openplaques.org")
    end
  end
end