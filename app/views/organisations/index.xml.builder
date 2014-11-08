xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => organisations_url()){
  @organisations.each do |organisation|
    xml.organisation(:uri => organisation_url(organisation)) {
      xml.name organisation.name
      xml.plaques_count organisation.sponsorships.size
    }
  end
}