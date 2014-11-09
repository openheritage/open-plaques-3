xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  xml.user(:id => user_url(@user), :created_at => @user.created_at.xmlschema, :updated_at => @user.updated_at.xmlschema) {
    xml.plaques(:count => @user.plaques.count)
  }


}
