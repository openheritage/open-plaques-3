xml.instruct! :xml, :version=>"1.0"
attributes = {:uri => verb_url(@verb)}
xml.openplaques(attributes){
  xml.verb(attributes) {
    xml.name @verb.name
    @verb.plaques.each do |plaque|
      xml.plaque(:link => plaque_url(plaque)) {
        xml.inscription plaque.inscription
      }
    end
    @verb.people.each do |person|
      xml.person(:link => person_url(person)) {
        xml.name person.name
      }
    end
  }
}