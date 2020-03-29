# A subject commemorated on a plaque
# === Attributes
# * +aka+ - array of names that person is also known as
# * +ancestry_id+ - link to Ancestry.com web site
# * +born_on+ - date on which the person was born [Optional]
# * +born_on_is_circa+ - true or false. Whether the +born_on+ date is 'circa' or not [Optional]
# * +dbpedia_uri+ - link to the DBpedia resource representing the person (if one exists).
# * +died_on+ - The date on which the person died [Optional]
# * +died_on_is_circa+ - true or false. Whether the +died_on+ date is 'circa' or not [Optional]
# * +find_a_grave_id+ - link to Find A Grave web site
# * +gender+ - (u)nkown, (n)ot applicable, (m)ale, (f)emale
# * +index+
# * +introduction+ -
# * +name+ - common full name of the person
# * +personal_connections_count+ - cached count of associations with plaques, i.e. places and times
# * +personal_roles_count+ - cached count of roles
# * +plaques_count+ - cached count of plaques
# * +surname_starts_with+ - letter to index this person on
# * +wikidata_id+ - Q-code to match to Wikidata
# * +wikipedia_url+ - override link to the person's Wikipedia page (if they have one and it isn't linked to via their name).
class Person < ApplicationRecord
  has_many :personal_roles, dependent: :destroy
  has_many :roles, -> { distinct }, through: :personal_roles
  has_many :personal_connections, dependent: :destroy
  has_many :plaques, -> { distinct }, through: :personal_connections
  has_one :birth_connection, -> { where('verb_id in (8,504)') }, class_name: 'PersonalConnection'
  has_one :death_connection, -> { where('verb_id in (3,49,161,1108)') }, class_name: 'PersonalConnection'
  has_one :main_photo, class_name: 'Photo'
  validates_presence_of :name
  before_save :update_index
  before_save :aka_accented_name
  before_save :fill_wikidata_id
  after_save :depiction_from_dbpedia
  scope :roled, -> { where('personal_roles_count > 0') }
  scope :unroled, -> { where(personal_roles_count: [nil, 0]) }
  scope :dated, -> { where('born_on IS NOT NULL or died_on IS NOT NULL') }
  scope :undated, -> { where('born_on IS NULL and died_on IS NULL') }
  scope :photographed, -> { joins(:main_photo) }
  scope :unphotographed, -> { where('id not in (select person_id from photos)') }
  scope :connected, -> { where('personal_connections_count > 0') }
  scope :unconnected, -> { where(personal_connections_count: [nil, 0]) }
  scope :name_starts_with, ->(term) { where(['name ILIKE ?', term.gsub(' ', '%') + '%']) }
  scope :name_contains, ->(term) { where(['name ILIKE ?', '%' + term.gsub(' ', '%') + '%']) }
  scope :name_is, ->(term) { where(['lower(name) = ?', term.downcase]) }
  scope :aka, ->(term) { where(["array_to_string(aka, ' ') ILIKE ?", term.gsub(' ', '%') + '%']) }
  scope :in_alphabetical_order, -> { order('name ASC') }
  scope :with_counts, lambda {
    select <<~SQL
      people.*,
      (
        select count(distinct plaque_id)
          FROM personal_connections
          WHERE personal_connections.person_id = people.id
      ) as plaques_count
    SQL
  }
  scope :female, -> { where(gender: 'f') }
  scope :ungendered, -> { where(gender: 'u') }
  scope :non_holocaust, -> { joins(:personal_roles).where('personal_roles.role_id != 5375') }

  DATE_REGEX = /c?[\d]{4}/.freeze
  DATE_RANGE_REGEX = /(?:\(#{DATE_REGEX}-#{DATE_REGEX}\)|#{DATE_REGEX}-#{DATE_REGEX})/.freeze

  def relationships
    @relationships ||= begin
      relationships = personal_roles.select(&:relationship?)
      relationships.sort { |a, b| a.started_at.to_s <=> b.started_at.to_s }
    end
  end

  def straight_roles
    @straight_roles ||= begin
      straight_roles = personal_roles.reject(&:relationship?)
      straight_roles.sort { |a, b| a.primary.to_s + a.started_at.to_s <=> a.primary.to_s + b.started_at.to_s }
    end
  end

  def primary_roles
    @primary_roles ||= begin
      primary_roles = personal_roles.select(&:primary?)
      # if >1 then cannot judge which is the 'best' role
      straight_roles if primary_roles == [] && straight_roles.size == 1
    end
  end

  def primary_role
    primary_roles&.first
  end

  def person?
    !(animal? || thing? || group? || place?)
  end

  def animal?
    roles.find(&:animal?) ? true : false
  end

  def thing?
    roles.find(&:thing?) ? true : false
  end

  def group?
    roles.find(&:group?) ? true : false
  end

  def place?
    roles.find(&:place?) ? true : false
  end

  def type
    return 'man' if person? && male?

    return 'woman' if person? && female?

    return 'person' if person?

    return 'animal' if animal?

    return 'thing' if thing?

    return 'place' if place?

    return 'group' if group?

    '?'
  end

  def born_in
    born_on&.year
  end

  def died_in
    died_on&.year
  end

  def dates
    dates = ''
    if born_in
      dates = '('
      dates << born_in.to_s
      if died_in
        dates << "-#{died_in}" if born_in != died_in
      else
        dates << (alive? ? '-present' : '-?')
      end
      dates << ')'
    elsif died_in
      dates = "(d.#{died_in})"
    end
    dates
  end

  def born_at
    birth_connection&.location
  end

  def died_at
    death_connection&.location
  end

  def dead?
    !died_in.nil? || (person? || animal?) && !born_in.nil? && born_in < 1910
  end

  def alive?
    !dead?
  end

  def existence_word
    alive? ? 'are' : 'were'
  end

  def age
    circa = died_on && born_on && born_on.month == 1 && born_on.day == 1 && died_on.month == 1 && died_on.day == 1
    return "c. #{(died_on.year - born_on.year)}" if circa

    if died_on && born_on
      a = died_on.year - born_on.year
      a -= 1 if born_on.month > died_on.month || (born_on.month >= died_on.month && born_on.day > died_on.day)
      return a.to_s
    end
    return Time.now.year - born_in if born_in && inanimate_object?

    return Time.now.year - born_in if born_in && born_in > 1910

    'unknown'
  end

  def fill_wikidata_id
    return if wikidata_id&.match(/Q\d*$/)

    t = name
    t = "#{name} (#{born_in}-#{died_in})" if born_in && died_in
    self.wikidata_id = Wikidata.qcode(t)
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
    return nil unless dbpedia_json

    begin
      dbpedia_json[dbpedia_uri.to_s]['http://dbpedia.org/ontology/abstract'].find { |abstract| abstract['lang'] == 'en' }['value']
    rescue
    end
  end

  def dbpedia_depiction
    return nil unless dbpedia_json

    begin
      dbpedia_json[dbpedia_uri.to_s]['http://xmlns.com/foaf/0.1/depiction'].first['value']
    rescue
    end
  end

  # call DBpedia and cache the response
  def dbpedia_json
    return @dbpedia_json if defined? @dbpedia_json

    @dbpedia_json = nil
    return @dbpedia_json if dbpedia_uri.blank?

    begin
      api = "#{dbpedia_uri.gsub('resource', 'data')}.json"
      response = URI.parse(api).open
      resp = response.read
      @dbpedia_json = JSON.parse(resp)
    rescue
    end
  end

  def name_and_dates
    "#{full_name} #{dates}"
  end

  def default_thumbnail_url
    '/assets/NoPersonSqr.png'
  end

  def current_personal_roles
    current = personal_roles.select(&:current?)
    current.sort! { |b, a| (a.role.priority && b.role.priority) ? a.role.priority <=> b.role.priority : (a.role.priority ? 1 : -1) }
    current
  end

  def current_roles
    current_personal_roles.collect(&:role)
  end

  def title
    title = ''
    current_personal_roles.each do |pr|
      if !pr.role.prefix.blank?
        # NB a clergyman or Commonwealth citizen does not get called 'Sir'
        title << "#{pr.role.prefix} " if !title.include?(pr.role.prefix) && !(pr.role.prefix == 'Sir' && clergy?)
      elsif pr.role.used_as_a_prefix? && !title.include?(pr.role.display_name)
        title << "#{role.display_name} "
      end
    end
    title.strip
  end

  def titled?
    title != ''
  end

  def clergy?
    roles.any? { |role| role.role_type == 'clergy' }
  end

  def letters
    letters = ''
    current_personal_roles.each do |pr|
      letters << " #{pr.suffix}" unless pr.role.suffix.blank? || letters.include?(pr.role.suffix)
    end
    letters.strip
  end

  def full_name
    "#{title} #{name} #{letters}".strip
  end

  def firstname
    name.split(' ').first
  end

  def surname
    name[name.downcase.rindex(" #{surname_starts_with.downcase}") ? name.downcase.rindex(" #{surname_starts_with.downcase}") + 1 : 0, name.size]
  end

  # a set of versions of a person's name, in precision order
  def names
    nameparts = name.split(' ')
    firstinitial = nameparts.second ? "#{firstname[0, 1]}." : ''
    secondname = nameparts.third ? nameparts.second : ''
    secondinitial = nameparts.third ? "#{secondname[0, 1]}." : ''
    middlenames = nameparts.length > 2 ? nameparts.from(1).to(nameparts.from(1).length - 2) : []
    middleinitials = ''
    middlenames.each_with_index do |name, index|
      middleinitials << ' ' if index.positive?
      middleinitials << "#{name.to_s[0, 1]}."
    end
    lastname = nameparts.last
    names = []
    names << full_name # Joseph Aloysius Hansom
    names << "#{title} #{name}" if titled? # Sir Joseph Aloysius Hansom
    names += aka # Boz, Charlie Cheese, and Crackers
    names << "#{title} #{firstinitial} #{middleinitials} #{lastname}" if titled? && nameparts.length > 2
    names << "#{title} #{firstinitial} #{lastname}" if titled? && nameparts.length > 1
    names << name if name != full_name # Joseph Aloysius Hansom
    if name.include? ',' # George Inn, Barcombe
      names << name.split(/,/).first
      return names
    end
    names << "#{title} #{name.split(/ of /).first}" if name.include?(' of ') && titled? # King Charles II [of England]
    names << name.split(/ of /).first if name.include?(' of ') # [King] Charles II [of England]
    names << "#{firstname} #{middleinitials} #{lastname}" if nameparts.length > 2 # Joseph A[loysius]. R[obert]. Hansom
    names << "#{firstinitial} #{middleinitials} #{lastname}" if nameparts.length > 2 # J. A. R. Hansom
    names << "#{firstname} #{nameparts.second} #{lastname}" if nameparts.length > 2 # Joseph Aaron Hansom
    names << "#{firstname} #{secondinitial} #{lastname}" if nameparts.length > 2 # Joseph A. Hansom
    names << "#{firstinitial} #{secondname} #{lastname}" if nameparts.length > 2 # J. Aaron Hansom
    names << "#{title} #{firstname} #{lastname}" if nameparts.length > 2 && titled? # Sir Joseph Hansom
    names << "#{firstname} #{lastname}" if nameparts.length > 2 # Joseph Hansom
    names << "#{firstinitial} #{lastname}" if nameparts.length > 1 # J. Hansom
    names << "#{title} #{lastname}" if titled? # Lord Carlisle
    names << "#{title} #{firstname}" if titled? # Sir William
    names << firstname if nameparts.length > 1 # Charles
    names << lastname if nameparts.length > 1 # Kitchener
    names.uniq
  end

  def father
    relationships.each do |relationship|
      return relationship.related_person if relationship.role.role_type == 'child' && !relationship.related_person.nil? && relationship.related_person.male?

    end
    nil
  end

  def mother
    relationships.each do |relationship|
      return relationship.related_person if relationship.role.role_type == 'child' && !relationship.related_person.nil? && relationship.related_person.female?

    end
    nil
  end

  def children
    issue = []
    relationships.each do |relationship|
      issue << relationship.related_person if relationship.role.role_type == 'parent'
    end
    issue.uniq.sort! { |a, b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def children?
    children.size.positive?
  end

  def siblings
    siblings = []
    father&.children&.each { |child| siblings << child if child != self }
    mother&.children&.each { |child| siblings << child if child != self }
    siblings.uniq.sort! { |a, b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def spouses
    people = []
    relationships.each do |relationship|
      people << relationship.related_person if relationship.role.role_type == 'spouse'
    end
    people
  end

  def spousal_relationships
    spousal_relationships = []
    relationships.each do |relationship|
      spousal_relationships << relationship if relationship.role.role_type == 'spouse'
    end
    spousal_relationships
  end

  def non_family_relationships
    non_family = []
    relationships.each do |relationship|
      non_family << relationship if relationship.role.family? != true
    end
    non_family
  end

  def family_relationships
    family = []
    relationships.each do |relationship|
      family << relationship if relationship.role.family? == true
    end
    family
  end

  def family?
    family_relationships.size.positive?
  end

  def creation_word
    return 'from' if thing?

    return 'formed in' if group?

    return 'built in' if place?

    'born in'
  end

  def destruction_word
    return 'until' if thing?

    return 'ended in' if group?

    return 'closed in' if place?

    'died in'
  end

  def inanimate_object?
    inanimate = gender == 'n' || thing? || group? || place?
    self.gender = 'n' if inanimate && gender != 'n'
    inanimate
  end

  def personal_pronoun
    return 'it' if inanimate_object?

    'they'
  end

  def male?
    if gender == 'u'
      self.gender = 'm' if
      %w[
        Abel Abraham
        Adam Adolf Adolphus Adrian
        Alan Albert Albie Alexander Alex Alfredo Alfred Alf Allen Alphonse
        Anatole Angelo Andrew Angus Antoine Antonio Anton
        Archibald Archie Arnold Arthur
        Augustus
        Barry
        Benjamin Ben Benedict Bernard
        Bill
        Bob Boris
        Brian Bryan
        Carlo Carl Caspar Casper
        Charles Christian Christopher
        Ciaran
        Claude
        Colin
        Cuthbert
        Cyril
        Daniel Dan Danny David Davey
        Dennis
        Dick
        Dominic
        Donald
        Duncan
        Edgar Edmund Edmond Edmund Edward Edwarde Edwardo Edwin
        Elias Elijah Elliott
        Eric Ernest Ernesto
        Felice Felix
        Filippo
        Francesco Francisco Francis Frank Fraser Frederic Frederick Fred
        Gaetano Gary Gavin
        George Georges Gerard
        Giacomo Giovanni Gilbert Giulio
        Gus
        Harold Harry
        Henri Henry Henryk Herbert Herman
        Horace Howard
        Hugh Humphrey
        Isaac
        Ivan
        Jack Jacob Jacques James
        Jean-Paul Jeremy
        Jimmy Jim
        John Johnny Jon Jonas Josiah Joseph
        Karl
        Kenneth Ken
        Laurent Lawrence
        Len Leonard Leopold Leo Lewis
        Lorenzo Louis
        Luciano Luigi
        Marcel Marco Maurice Martin Matthew Matt Matthias
        Michael Michel Mick
        Montague Montgomery
        Murray
        Nathan
        Neil
        Noah Norman
        Nicholas Nick Nicolas
        Owen
        Patrick Paul
        Pedro Percy Peter Petr
        Philip Philippe
        Pierre Pietro
        Raffaello Ralph Raymond Ray
        Rees Reginald Reg Reggie
        Richard
        Robert Roberto Rod Roger Roland Rory Ross Rowland Roy
        Russell Russ
        Samuel
        Sebastian
        Sergey
        Sidney Sid Simon
        Solomon
        Spencer
        Stanley Stephen Steve Steven Stewart
        Stuart
        Terry
        Theodorus Theo Thomas
        Tommy Tom
        Ugo
        Vincent Vince Vincenzo
        Waldo Walter
        Wilfred Wilf William Will Willie
        Zachariah Zachary Zach
      ].include?(firstname)
    end
    !female?
  end

  def female?
    if gender == 'u'
      self.gender = 'f' if roles.any?(&:female?)
      self.gender = 'f' if
      %w[
        Abigail
        Adelaide Adele Ada
        Agnes
        Alessandra Alexandra Alice Alison
        Amalie Amelia
        Anastasia Ann Anna Anne Annie Antoinette
        Beatriz
        Bertha
        Betsy Betsey Betty
        Brenda
        Caroline Cäcilie
        Charlotte
        Clara
        Constance
        Daisy
        Deborah
        Diana
        Dolly Doris Dorothea Dorothy
        Edith
        Elaine Elfriede Elisabeth Elise Elizabeth Ella Ellen Elly Elsbeth Elsa Else Elsie
        Emilie Emily Emma
        Erika Erna Ernestine
        Eva
        Fanny
        Flora Florence
        Franziska Frida Frieda
        Georgia Georgina Gerda Gertrud Gertrude
        Gladys
        Grace Greta Grete
        Hanna Hattie Hazel
        Helen Helene Henrietta Henriette Herta Hertha
        Hilde Hildegard
        Ida
        Ilse Irene Irma
        Jane Janet Jacqueline
        Jeanne Jenny Jennifer
        Johanna Josephine
        Judith Julia Julie
        Kate Käte Käthe Katherine Kathleen
        Klara
        Laura
        Letitia
        Lidia Lina Liz
        Lotte Louise Louisa
        Lucie Lucy Luise
        Mabel Mala Margaret Margery Margot Maria Marianne Marie Martha Mary Maryse Mathilde May
        Mercy Meta
        Minna Minnie
        Monica Monika
        Nancy
        Nelly Nellie
        Olga
        Paloma Paula Pauline
        Peggy
        Phoebe
        Priscilla
        Rachel
        Regina
        Roberta Rosa Rose Rosemary
        Ruth
        Sally Sarah Sara
        Selma
        Shelley
        Sonia Sophie
        Susan Susanna
        Toni Therese
        Ursula
        Vera
        Victoria Violet Virginia
        Wilhelmina Winifred
      ].include?(firstname)
      self.gender = 'm' unless inanimate_object?
    end
    gender == 'f'
  end

  def sex
    return 'female' if female?

    return 'object' if inanimate_object?

    'male'
  end

  def possessive
    return 'its' if inanimate_object?

    return 'their' if female?

    return 'their' if male?

    'their'
  end

  def related_to?(person)
    relationships.each do |r|
      return true if r.related_person == person
    end
    false
  end

  def find_a_grave_url
    "http://www.findagrave.com/cgi-bin/fg.cgi?page=gr&GRid=#{find_a_grave_id}" if find_a_grave_id && !find_a_grave_id&.blank?
  end

  def ancestry_url
    "http://www.ancestry.co.uk/genealogy/records/#{ancestry_id}" if ancestry_id && !ancestry_id&.blank?
  end

  def self.search(term)
    cap = 20 # to protect from stupid searches like "%a%"
    matches = []
    name = term
    name_and_dates = term.match(/(.*) \((\d\d\d\d)\s*-*\s*(\d\d\d\d)\)/)
    if name_and_dates
      name = name_and_dates[1]
      born = name_and_dates[2]
      died = name_and_dates[3]
    end
    @people = []
    unaccented_phrase = name.tr("’ßÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
"'sAAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")
    full_phrase_like = "%#{name}%"
    phrase_like = "%#{name.tr(' ', '%').tr('.', '%')}%"
    unaccented_phrase_like = "%#{unaccented_phrase.tr(' ', '%').tr('.', '%')}%"
    @people += Person.where(['name ILIKE ?', full_phrase_like]).limit(cap)
    @people += Person.where(['name ILIKE ?', phrase_like]).limit(cap)
    @people += Person.where(['name ILIKE ?', unaccented_phrase_like]).limit(cap) if name.match(/[À-ž]/)
    @people += Person.where(["array_to_string(aka, ' ') ILIKE ?", full_phrase_like]).limit(cap)
    @people += Person.where(["array_to_string(aka, ' ') ILIKE ?", phrase_like]).limit(cap)
    @people += Person.where(["array_to_string(aka, ' ') ILIKE ?", unaccented_phrase_like]).limit(cap) if name.match(/[À-ž]/)
    @people.uniq!
    if name_and_dates
      exact_matches = @people.find_all { |person| person.born_in.to_i == born.to_i && person.died_in.to_i == died.to_i }
      matches = exact_matches.nil? ? exact_matches : @people
    else
      matches = @people
    end
    matches
  end

  def uri
    "https://openplaques.org#{Rails.application.routes.url_helpers.person_path(self, format: :json)}"
  end

  def machine_tag
    "openplaques:subject:id=#{id}"
  end

  def to_s
    name
  end

  def as_json(options = nil)
    if options && options[:only]
    else
      options = {
        only: [],
        include: {
          personal_roles: {
            only: [],
            include: {
              role: {
                only: :name,
                methods: [:uri]
              },
              related_person: {
                only: [], methods: %i[uri full_name]
              }
            }
          }
        },
        methods: %i[
          uri
          name_and_dates
          full_name
          surname
          born_in
          died_in
          type
          sex
          primary_role
          wikidata_id
          wikipedia_url
          dbpedia_uri
          find_a_grave_url
        ]
      }
    end
    super(options)
  end

  def update_index
    self.index = name[0, 1].downcase
    if surname_starts_with.blank?
      self.surname_starts_with = name[name.rindex(' ') ? name.rindex(' ') + 1 : 0, 1].downcase
    end
    surname_starts_with.downcase!
  end

  def unaccented_name
    name.tr('ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž',
'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz')
  end

  def accented_name?
    name != unaccented_name
  end

  def aka_accented_name
    return unless accented_name? && !aka.include?(unaccented_name)

    aka_will_change!
    aka.push(unaccented_name)
  end

  def depiction_from_dbpedia
    return unless !main_photo && dbpedia_depiction

    begin
      photo = Photo.new(url: dbpedia_depiction, person: self)
      photo.populate
      photo.save
    rescue
    end
  end
end
