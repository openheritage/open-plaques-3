xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  xml.role(:uri => role_url(@role), :created_at => @role.created_at.xmlschema, :updated_at => @role.updated_at.xmlschema){
    xml.name @role.name
	@role.people.each do |person|
	  xml.person(:uri => person_url(person)) {
	    xml.name person.name
	    xml.other_roles {
		  person.roles.each do |role|
		    xml.role(:uri => role_url(role)) {
			  xml.text! role.name
		    } unless role == @role
		  end
	    } unless person.roles.size == 1
	  }
	end
  }
  @role.related_roles.each do |role|
	xml.related_role(:uri => role_url(role)) {
	  xml.text! role.name
	}
  end
}
