class PlaqueCsv < Julia::Builder
  column :id
  column :title
  column :inscription
  column :latitude
  column :longitude
  column 'country' do |plaque| plaque.area ? plaque.area.country.name : '' end
  column 'area' do |plaque| plaque.area ? plaque.area.name : '' end
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
  column 'lead_subject_name' do |plaque| plaque.people.first ? plaque.people.first.name : '' end
  column 'lead_subject_born_in' do |plaque| plaque.people.first ? plaque.people.first.born_in : '' end
  column 'lead_subject_died_in' do |plaque| plaque.people.first ? plaque.people.first.died_in : '' end
  column 'lead_subject_type' do |plaque| plaque.people.first ? plaque.people.first.type : '' end
  column 'lead_subject_roles' do |plaque|
    subject = plaque.people.first
    roles = []
    subject.personal_roles.each do |personal_role| roles << personal_role.name end if subject
    roles
  end
  column 'lead_subject_wikipedia' do |plaque| plaque.people.first ? plaque.people.first.default_wikipedia_url : '' end
  column 'lead_subject_dbpedia' do |plaque| plaque.people.first ? plaque.people.first.default_dbpedia_uri : '' end
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