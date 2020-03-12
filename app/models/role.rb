# A role ascribed to a subject.
# These can be professions (eg 'doctor'), occupations ('artist'), or activities ('inventor').
# === Attributes
# * +abbreviation+ - acronym etc. when a role is commonly abbreviated, especially awards, e.g. Victoria Cross == VC
# * +description+
# * +index+ - letter indexed on
# * +name+ - what the role is called
# * +personal_roles_count+ - number of people with this role
# * +prefix+ - word(s) to display as part of a title in a name
# * +priority+ -
# * +role_type+ - The classification of the role (see self.types for choice)
# * +slug+ -
# * +suffix+ - word(s) to display as part of letters after a name
# * +wikidata_id+ - calculated Qnnnnn code, set to 'Q' if not found
class Role < ApplicationRecord
  has_many :personal_roles, -> { order(:started_at) }
  has_many :people, -> { order(:name) }, through: :personal_roles

  before_validation :make_slug_not_war
  before_save :update_index
  before_save :filter_name
  before_save :fill_wikidata_id
  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  scope :by_popularity, -> { order('personal_roles_count DESC nulls last') }
  scope :alphabetically, -> { order('name ASC nulls last') }
  scope :name_starts_with, lambda {|term| where(['lower(name) LIKE ?', "#{term.downcase}%"]) }
  scope :name_contains, lambda {|term| where(['lower(name) LIKE ?', "%#{term.downcase }%"]) }
  scope :name_is, lambda { |term| where(['lower(name) = ?', term.downcase]) }
  scope :in_alphabetical_order, -> { order('name ASC') }

  include ApplicationHelper

  def related_roles
    Role.where(['lower(name) != ? and (lower(name) LIKE ? or lower(name) LIKE ? or lower(name) LIKE ? )', name.downcase,
    "#{name.downcase} %", "% #{name.downcase} %", "% #{name.downcase}"])
  end

  def self.types
    ['person', 'man', 'woman', 'animal', 'thing', 'group', 'place', 'relationship', 'parent', 'spouse', 'child', 'title', 'letters', 'military medal', 'clergy']
  end

  def person?
    return false if animal? or thing? or group? or place?
	  return true
  end

  def animal?
    return true if 'animal' == role_type
	  return false
  end

  def thing?
    return true if 'thing' == role_type
    return false
  end

  def group?
    return true if 'group' == role_type
    return false
  end

  def place?
    return true if 'place' == role_type
    return false
  end

  def family?
    return true if role_type == 'parent'
    return true if role_type == 'child'
    return true if role_type == 'spouse'
    # redundant roles
    return true if name == 'brother'
    return true if name == 'sister'
    return true if name == 'half-brother'
    return true if name == 'half-sister'
    false
  end

  def type
	  return 'person' if person?
	  return 'animal' if animal?
	  return 'thing' if thing?
	  return 'group' if group?
	  return 'place' if place?
	  return '?'
  end

  def fill_wikidata_id
    unless wikidata_id&.match /Q\d*$/
      self.wikidata_id = Wikidata.qcode(name)
      dbpedia_abstract
    end
    if wikidata_id&.match(/Q\d*$/) && description.blank?
      dbpedia_abstract
    end
  end

  def wikidata_url
    "https://www.wikidata.org/wiki/#{wikidata_id}" if wikidata_id && !wikidata_id&.blank? && wikidata_id != 'Q'
  end

  def wikipedia_url
    Wikidata.new(wikidata_id).en_wikipedia_url
  end

  def dbpedia_uri
    wikipedia_url&.gsub('en.wikipedia.org/wiki', 'dbpedia.org/resource')&.gsub('https', 'http')
  end

  def dbpedia_abstract
    return description unless description.blank?

    return nil if dbpedia_uri.blank?

    api = "#{dbpedia_uri.gsub('resource','data')}.json"
    begin
      response = open(api)
      resp = response.read
      parsed_json = JSON.parse(resp)
      self.description = parsed_json["#{dbpedia_uri}"]['http://dbpedia.org/ontology/abstract'].find {|abstract| abstract['lang']=='en'}['value']
    rescue
    end
  end

  def relationship?
    relationship_role_types = ['relationship', 'parent', 'spouse', 'child', 'group']
    relationship_role_types.include?(role_type)
  end

  def used_as_a_prefix?
    !prefix.blank?
  end

  def military_medal?
    role_type == 'military medal'
  end

  def used_as_a_suffix?
    !suffix.blank?
  end

  def letters
    used_as_a_suffix? ? suffix : ''
  end

  def abbreviated?
    !abbreviation.blank?
  end

  def confers_honourific_title?
    return true if 'Baronet' == name
    return true if 'Baroness' == name
    return true if 'Knight Bachelor' == name
    return true if 'Knight of the Order of the Garter' == name
    return true if 'Knight of the Order of the Thistle' == name
    return true if 'Knight Commander of the Order of the Bath' == name
    return true if 'Knight Grand Cross of the Order of the Bath' == name
    return true if 'Knight Commander of the Order of St Michael and St George' == name
    return true if 'Knight Grand Cross of the Order of St Michael and St George' == name
    return true if 'Knight Commander of the Royal Victorian Order' == name
    return true if 'Knight Grand Cross of the Royal Victorian Order' == name
    return true if 'Knight Commander of the Order of the British Empire' == name
    return true if 'Knight Grand Cross of the Order of the British Empire' == name
    return true if 'Lady' == name
    false
  end

  def female?
    return true if 'woman' == role_type

    female_relatives = ['wife', 'sister', 'half-sister', 'daughter', 'mother']
    return true if female_relatives.include?(name)

    ennobled_females = ['Baroness', 'Dame', 'Dame Commander of the Most Excellent Order of the British Empire', 'Dame Commander of the Royal Victorian Order', 'Empress', 'Lady', 'Queen']
    return true if ennobled_females.include?(name)

    female_job_titles = ['Woman Police Constable']
    return true if female_job_titles.include?(name)

    return true if name.start_with?('Viscountess')

    false
  end

  def male?
    !self.female?
  end

  def full_name
    return "#{abbreviation} - #{name}" if abbreviated?
    name
  end

  def display_name
    abbreviated? ? abbreviation : name
  end

  def sticky?
    name == 'President of the Royal Society' || prefix == 'King' || prefix == 'Queen'
  end

  def pluralize
    full_name.include?(' of ') ?
      name.split(/#| of /).first.pluralize + name.sub(/.*? of /, ' of ')
      : name.pluralize
  end

  def uri
    'http://openplaques.org' + Rails.application.routes.url_helpers.role_path(self.slug, format: :json)
  end

  def to_s
    name
  end

  def as_json(options={})
    options = {
      only: [:name, :personal_roles_count, :role_type, :abbreviation],
      methods: [:type, :full_name, :male?, :relationship?, :confers_honourific_title?]
    } if !options || !options[:only]
    super options
  end

  private

  def update_index
    self.index = self.name[0,1].downcase
  end

  def filter_name
    self.name = name.gsub(/\.?\??/, '').strip
  end

end
