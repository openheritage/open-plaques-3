xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => area_url(@area)){
  xml.area(:uri => area_url(@area)) {
    xml.name @area.name
    xml.country(:uri => country_url(@area.country)) {
      xml.name @area.country.name
    }
    @area.plaques.each do |plaque|
      xml.plaque(:uri => plaque_url(plaque)) {
        xml.name plaque.title
        if plaque.geolocated?
          xml.geo(:reference_system => "WGS84", :latitude => plaque.latitude, :longitude => plaque.longitude)
        end
      }
    end
  }
}