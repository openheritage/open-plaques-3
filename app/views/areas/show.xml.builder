xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => area_url(@area)){
  xml.area(:uri => area_url(@area)) {
    xml.name @area.name
    xml.country(:uri => country_url(@area.country)) {
      xml.name @area.country.name
    }
  }
}