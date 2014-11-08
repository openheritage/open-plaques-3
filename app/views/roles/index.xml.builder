xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  @roles.each do |role|
  xml.role(:uri => role_url(role), :updated_at => role.updated_at.xmlschema){
    xml.name role.name
  }
  end
}