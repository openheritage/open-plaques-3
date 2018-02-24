class PersonCsv < Julia::Builder
  column :id
  column :machine_tag
  column :full_name
  column :surname
  column :type
  column :born_in
  column :died_in
  column :age do |person|
    person.age.to_s.gsub('c. ','')
  end
  column :sex
  column 'roles' do |person|
    roles = []
    person.roles.each do |role| roles << role.name end
    roles
  end
  column :primary_role do |person|
    person.primary_role&.role&.name
  end
  column :clergy?
  column 'mother' do |person|
    person.mother&.full_name
  end
  column 'mother_id' do |person|
    person.mother&.id
  end
  column 'father' do |person|
    person.father&.full_name
  end
  column 'father_id' do |person|
    person.father&.id
  end
  column :wikidata_id
  column 'en_wikipedia_url' do |person|
    person.wikipedia_url
  end
  column :dbpedia_uri
  column :find_a_grave_url
  column :plaques_count
end
