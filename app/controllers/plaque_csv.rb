class PlaqueCsv < Julia::Builder
  column :id
  column :machine_tag
  column :title
  column 'inscription' do |plaque| plaque.inscription.gsub(/\r/," ").gsub(/\n/," ") end
  column :latitude
  column :longitude
  column :as_wkt
  column 'country' do |plaque| plaque.area ? plaque.area.country.name : '' end
  column 'area' do |plaque| plaque.area ? plaque.area.name : '' end
  column :address
  column 'erected' do |plaque| plaque.erected_at ? plaque.erected_at.year.to_s : '' end
  column 'main_photo' do |plaque| plaque.main_photo ? plaque.main_photo.file_url : '' end
  column 'colour' do |plaque| plaque.colour ? plaque.colour.name : '' end
  column 'organisations' do |plaque|
    orgs = []
    plaque.organisations.each do |org| orgs << org.name end
    orgs
  end
  column 'language' do |plaque| plaque.language ? plaque.language.name : '' end
  column 'series' do |plaque| plaque.series ? plaque.series.name : '' end
  column 'series_ref'
  column 'geolocated?'
  column 'photographed?'
  column 'number_of_subjects' do |plaque|
    plaque.people.count
  end
  column 'lead_subject_id' do |plaque| plaque.people.first ? plaque.people.first.id : '' end
  column 'lead_subject_machine_tag' do |plaque| plaque.people.first ? plaque.people.first.machine_tag : '' end
  column 'lead_subject_name' do |plaque| plaque.people.first ? plaque.people.first.name : '' end
  column 'lead_subject_surname' do |plaque| plaque.people.first ? plaque.people.first.name : '' end
  column 'lead_subject_born_in' do |plaque| plaque.people.first ? plaque.people.first.born_in : '' end
  column 'lead_subject_died_in' do |plaque| plaque.people.first ? plaque.people.first.died_in : '' end
  column 'lead_subject_type' do |plaque| plaque.people.first ? plaque.people.first.type : '' end
  column 'lead_subject_roles' do |plaque|
    subject = plaque.people.first
    roles = []
    subject.personal_roles.each do |personal_role| roles << personal_role.name end if subject
    roles
  end
  column 'lead_subject_primary_role' do |plaque|
    plaque.people.first && plaque.people.first.primary_role ? plaque.people.first.primary_role&.role.name : ''
  end
  column 'lead_subject_wikipedia' do |plaque| plaque.people.first ? plaque.people.first.wikipedia_url : '' end
  column 'lead_subject_dbpedia' do |plaque| plaque.people.first ? plaque.people.first.dbpedia_uri : '' end
  column 'lead_subject_image' do |plaque|
    plaque.people.first ? plaque.people.first.main_photo ? plaque.people.first.main_photo.file_url : '' : ''
  end
  column 'subjects' do |plaque|
    subjects = []
    plaque.people.each do |subject|
      roles = []
      subject.personal_roles.each do |personal_role| roles << personal_role.name end
      subjects << subject.name + '|' + subject.dates.to_s + '|' + subject.type + '|' + roles.to_sentence
    end
    subjects
  end
#    column 'Full name', -> { "#{ name.capitalize } #{ last_name.capitalize }" }
end
