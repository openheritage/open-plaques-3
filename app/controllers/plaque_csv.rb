# define Plaque CSV format
class PlaqueCsv < Julia::Builder
  column :id
  column :machine_tag
  column :title
  column 'inscription' do |plaque| plaque.inscription.gsub(/\r/, ' ').gsub(/\n/, ' ') end
  column :latitude
  column :longitude
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
  column 'number_of_male_subjects' do |plaque|
    men = plaque.people.select { |subject| subject.male? }
    men.count
  end
  column 'number_of_female_subjects' do |plaque|
    women = plaque.people.select { |subject| subject.female? }
    women.count
  end
  column 'number_of_inanimate_subjects' do |plaque|
    inanimate = plaque.people.select { |subject| subject.inanimate_object? }
    inanimate.count
  end
  column 'lead_subject_id' do |plaque| plaque.lead_subject ? plaque.lead_subject.id : '' end
  column 'lead_subject_machine_tag' do |plaque| plaque.lead_subject ? plaque.lead_subject.machine_tag : '' end
  column 'lead_subject_name' do |plaque| plaque.lead_subject ? plaque.lead_subject.name : '' end
  column 'lead_subject_surname' do |plaque| plaque.lead_subject ? plaque.lead_subject.surname : '' end
  column 'lead_subject_sex' do |plaque| plaque.lead_subject ? plaque.lead_subject.sex : '' end
  column 'lead_subject_born_in' do |plaque| plaque.lead_subject ? plaque.lead_subject.born_in : '' end
  column 'lead_subject_died_in' do |plaque| plaque.lead_subject ? plaque.lead_subject.died_in : '' end
  column 'lead_subject_type' do |plaque| plaque.lead_subject ? plaque.lead_subject.type : '' end
  column 'lead_subject_roles' do |plaque|
    plaque.lead_subject&.role_names || []
  end
  column 'lead_subject_primary_role' do |plaque|
    plaque.lead_subject&.primary_role&.name || ''
  end
  column 'lead_subject_wikipedia' do |plaque| plaque.lead_subject&.wikipedia_url || '' end
  column 'lead_subject_dbpedia' do |plaque| plaque.lead_subject&.dbpedia_uri || '' end
  column 'lead_subject_image' do |plaque|
    plaque.lead_subject ? plaque.lead_subject.main_photo ? plaque.lead_subject.main_photo.file_url : '' : ''
  end
  column 'subjects' do |plaque|
    subjects = []
    plaque.people.each do |subject|
      roles = []
      subject.personal_roles.each { |personal_role| roles << personal_role.name }
      subjects << subject.name + '|' + subject.dates.to_s + '|' + subject.type + '|' + roles.to_sentence
    end
    subjects
  end
  #    column 'Full name', -> { "#{ name.capitalize } #{ last_name.capitalize }" }
end
