xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => organisation_url(@organisation)){
  attributes = {:uri => organisation_url(@organisation), :updated_at => @organisation.updated_at.xmlschema}
  xml.organisation(attributes) {
    xml.name @organisation.name
    xml.website @organisation.website unless @organisation.website.blank?
    xml.description @organisation.description
    @organisation.plaques.each do |plaque|
      xml.plaque(:uri => plaque_url(plaque)) {
        xml.title plaque.title
        xml.colour plaque.colour_name if plaque.colour_name
        xml.inscription plaque.inscription
        xml.geo(:reference_system => "WGS84", :latitude => plaque.latitude, :longitude => plaque.longitude) if plaque.geolocated?
      }
    end
  }
}