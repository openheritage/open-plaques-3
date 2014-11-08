xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => photographers_url()){
  @photographers.each do |photographer|
    xml.photographer(:uri => photographer_url(photographer[0])) {
      xml.id photographer[0]
      xml.count photographer[1]
    }
  end
}