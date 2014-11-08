xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  @verbs.each do |verb|
    xml.verb(:uri => verb_url(verb)) {
      xml.name verb.name
    }
  end
}