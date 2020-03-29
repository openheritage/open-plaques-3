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
  scope :name_starts_with, ->(term) { where(['lower(name) LIKE ?', "#{term.downcase}%"]) }
  scope :name_contains, ->(term) { where(['lower(name) LIKE ?', "%#{term.downcase}%"]) }
  scope :name_is, ->(term) { where(['lower(name) = ?', term.downcase]) }
  scope :in_alphabetical_order, -> { order(name: :asc) }

  include ApplicationHelper

  def related_roles
    Role.where(
      [
        'lower(name) != ? and (lower(name) LIKE ? or lower(name) LIKE ? or lower(name) LIKE ? )',
        name.downcase,
        "#{name.downcase} %",
        "% #{name.downcase} %",
        "% #{name.downcase}"
      ]
    )
  end

  def self.types
    [
      'person',
      'man',
      'woman',
      'animal',
      'thing',
      'group',
      'place',
      'relationship',
      'parent',
      'spouse',
      'child',
      'title',
      'letters',
      'military medal',
      'clergy'
    ]
  end

  def person?
    !(animal? || thing? || group? || place?)
  end

  def animal?
    role_type == 'animal'
  end

  def thing?
    role_type == 'thing'
  end

  def group?
    role_type == 'group'
  end

  def place?
    role_type == 'place'
  end

  def family?
    %w[parent child spouse].include?(role_type) ||
      %w[brother sister half-brother half-sister].include?(name)
  end

  def type
    return 'person' if person?

    return 'animal' if animal?

    return 'thing' if thing?

    return 'group' if group?

    return 'place' if place?
  end

  def fill_wikidata_id
    unless wikidata_id&.match(/Q\d*$/)
      self.wikidata_id = Wikidata.qcode(name)
      dbpedia_abstract
    end
    dbpedia_abstract if wikidata_id&.match(/Q\d*$/) && description.blank?
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

    api = "#{dbpedia_uri.gsub('resource', 'data')}.json"
    begin
      response = URI.parse(api).open
      resp = response.read
      parsed_json = JSON.parse(resp)
      abstract = parsed_json[dbpedia_uri]['http://dbpedia.org/ontology/abstract']
      self.description = abstract.find { |txt| txt['lang'] == 'en' }['value']
    rescue
    end
  end

  def relationship?
    %w[relationship parent spouse child group].include?(role_type)
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
    [
      'Baronet', 'Baroness',
      'Knight Bachelor',
      'Knight of the Order of the Garter', 'Knight of the Order of the Thistle',
      'Knight Commander of the Order of the Bath', 'Knight Grand Cross of the Order of the Bath',
      'Knight Commander of the Order of St Michael and St George', 'Knight Grand Cross of the Order of St Michael and St George',
      'Knight Commander of the Royal Victorian Order', 'Knight Grand Cross of the Royal Victorian Order',
      'Knight Commander of the Order of the British Empire', 'Knight Grand Cross of the Order of the British Empire',
      'Lady'
    ].include?(name)
  end

  def ennobled_female?
    [
      'Baroness',
      'Dame',
      'Dame Commander of the Most Excellent Order of the British Empire',
      'Dame Commander of the Royal Victorian Order',
      'Empress',
      'Lady',
      'Queen'
    ].include?(name) || name.start_with?('Viscountess')
  end

  def female?
    role_type == 'woman' ||
      %w[wife sister half-sister daughter mother].include?(name) ||
      ennobled_female? ||
      ['Woman Police Constable'].include?(name)
  end

  def male?
    !female?
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
    if full_name.include?(' of ')
      name.split(/#| of /).first.pluralize + name.sub(/.*? of /, ' of ')
    else
      name.pluralize
    end
  end

  def uri
    'http://openplaques.org' + Rails.application.routes.url_helpers.role_path(slug, format: :json)
  end

  def to_s
    name
  end

  def as_json(options = {})
    if !options || !options[:only]
      options = {
        only: %i[name personal_roles_count role_type abbreviation],
        methods: %i[type full_name male? relationship? confers_honourific_title?]
      }
    end
    super options
  end

  private

  def update_index
    self.index = name[0, 1].downcase
  end

  def filter_name
    self.name = name.gsub(/\.?\??/, '').strip
  end
end
