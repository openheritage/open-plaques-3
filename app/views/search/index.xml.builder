xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  xml.search_results() {
    @search_results.each do |result|
      begin
        # is it a plaque?
        plaque = result
        plaque.inscription
        xml.plaque(:uri => plaque_url(plaque)) {
          xml.title plaque.title
          xml.colour plaque.colour_name
          xml.inscription plaque.inscription
          xml.geo(:reference_system => "WGS84", :latitude => plaque.latitude, :longitude => plaque.longitude)
        }
      rescue
        begin
          # is it a person?
          person = result
          person.born_in
      	  xml.person(:uri => person_url(person)) {
      	    xml.name person.name
            xml.born {
      	      xml.in { xml.text! person.born_in.to_s } unless person.born_in.blank?
      	      xml.at(:uri => location_url(person.born_at.id)) {
      		      xml.text! person.born_at.full_address
      	      } unless person.born_at == nil or person.born_at.blank?
            } unless person.born_in.blank? and person.born_at.blank?
            xml.died {
              xml.in { xml.text! person.died_in.to_s } unless person.died_in.blank?
              xml.at(:uri => location_url(person.died_at.id)) {
                xml.text! person.died_at.full_address
              } unless person.died_at.blank?
              xml.age person.age
      	    } unless person.died_in.blank? and person.died_at.blank?
      	    xml.wikipedia(:uri => person.default_wikipedia_url) unless person.default_wikipedia_url.blank?
      	    xml.dbpedia(:uri => person.default_dbpedia_uri) unless person.default_dbpedia_uri.blank?
      	  }
        rescue
        end
      end
    end
  }
}