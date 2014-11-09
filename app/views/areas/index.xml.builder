xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => areas_url()){
  @areas.each do |area|
    xml.area(:uri => area_url(area)) {
      xml.name area.name
    }
  end
}