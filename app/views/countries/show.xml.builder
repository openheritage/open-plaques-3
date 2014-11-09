xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => country_url(@country)){
  xml.country(:uri => country_url(@country)) {
    xml.name @country.name
    @country.areas.each do |area|
      xml.area(:uri => area_url(area)) {
        xml.name area.name
      }
    end
  }
}