xml.instruct! :xml, :version=>"2.0"
xml.rss(:version=>"2.0", "xmlns:georss" => "http://www.georss.org/georss"){
  xml.channel {
    xml.title("OpenPlaques.org")
    xml.link("http://openplaques.org/")
    xml.description("My posts enhanced with location info")
    xml.language('en-gb')
    for plaque in @plaques
      xml.item(){
        xml.title("Plaque ", plaque.id)
        xml.link(plaque_url(plaque))
        xml.created_at(plaque.created_at.xmlschema)
        xml.updated_at(plaque.updated_at.xmlschema)
        xml.description(plaque.inscription)
        if plaque.latitude && plaque.longitude
          xml.georss :point do
            xml.text! plaque.latitude.to_s + ' ' + plaque.longitude.to_s
          end
        end
      }
    end
  }
}
