xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  xml.role_index(:link => roles_by_index_url(params[:id])) {
    xml.roles {
      @roles.each do |role|
        xml.role(:link => role_url(role.name)) {
          xml.name role.name
          xml.people(:count => role.personal_roles_count)
        }
      end
    }
  }
}