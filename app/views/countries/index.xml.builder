xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => countries_url()){
  @countries.each do |country|
    xml.country(:uri => country_url(country)) {
      xml.name country.name
    }
  end
}