xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => people_by_index_url(@index)){
  xml.index_letter @index
  @people.each do |person|
    xml.person(:uri => person_url(person)) {
      xml.name person.name
    }
  end
}
