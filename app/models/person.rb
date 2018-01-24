# A subject commemorated on a plaque
# === Attributes
# * +name+ - common full name of the person
# * +born_on+ - date on which the person was born [Optional]
# * +died_on+ - The date on which the person died [Optional]
# * +plaques_count+ - cached count of plaques
# * +created_at+
# * +updated_at+
# * +personal_connections_count+ - cached count of associations with plaques, i.e. places and times
# * +personal_roles_count+ - cached count of roles
# * +index+
# * +born_on_is_circa+ - true or false. Whether the +born_on+ date is 'circa' or not [Optional]
# * +died_on_is_circa+ - true or false. Whether the +died_on+ date is 'circa' or not [Optional]
# * +wikipedia_url+ - override link to the person's Wikipedia page (if they have one and it isn't linked to via their name).
# * +dbpedia_uri+ - link to the DBpedia resource representing the person (if one exists).
# * +surname_starts_with+ - letter to index this person on
# * +introduction+ -
# * +gender+ - (u)nkown, (n)ot applicable, (m)ale, (f)emale
# * +aka+ - array of names that person is also known as
# * +find_a_grave_id+ - link to Find A Grave web site
# * +ancestry_id+ - link to Ancestry.com web site
class Person < ApplicationRecord

  has_many :personal_roles
  has_many :personal_connections
  has_many :roles, -> { distinct }, through: :personal_roles
  has_many :plaques, -> { distinct }, through: :personal_connections
  has_one :birth_connection, -> { where('verb_id in (8,504)') }, class_name: "PersonalConnection"
  has_one :death_connection, -> { where('verb_id in (3,49,161,1108)') }, class_name: "PersonalConnection"
  has_one :main_photo, class_name: "Photo"

  validates_presence_of :name
  before_save :update_index
  before_save :aka_accented_name
  before_save :fill_wikidata_id
  after_save :depiction_from_dbpedia
  scope :roled, -> { where("personal_roles_count > 0").order("id DESC") }
  scope :unroled, -> { where(personal_roles_count: [nil,0]) }
  scope :dated, -> { where("born_on IS NOT NULL or died_on IS NOT NULL") }
  scope :undated, -> { where("born_on IS NULL and died_on IS NULL") }
  scope :photographed, -> { joins(:main_photo) }
  scope :unphotographed, -> { where("id not in (select person_id from photos)").order("id DESC") }
  scope :connected, -> { where("personal_connections_count > 0").order("id DESC") }
  scope :unconnected, -> { where(personal_connections_count: [nil,0]).order("id DESC") }
  scope :name_starts_with, lambda { |term| where(["lower(name) LIKE ?", term.downcase + "%"]) }
  scope :name_contains, lambda { |term| where(["lower(name) LIKE ?", "%" + term.downcase + "%"]) }
  scope :with_counts, -> {
    select <<~SQL
      people.*,
      (
        select count(distinct plaque_id)
          FROM personal_connections
          WHERE personal_connections.person_id = people.id
      ) as plaques_count
    SQL
  }

  DATE_REGEX = /c?[\d]{4}/
  DATE_RANGE_REGEX = /(?:\(#{DATE_REGEX}-#{DATE_REGEX}\)|#{DATE_REGEX}-#{DATE_REGEX})/

  def relationships
    @relationships ||= begin
      relationships = personal_roles.select do |personal_role|
        personal_role.related_person_id != nil
      end
      relationships.sort { |a,b| a.started_at.to_s <=> b.started_at.to_s }
    end
  end

  def straight_roles
    @straight_roles ||= begin
      straight_roles = personal_roles.select { |personal_role| personal_role.related_person_id == nil }
      straight_roles.sort { |a,b| a.primary.to_s + a.started_at.to_s <=> a.primary.to_s + b.started_at.to_s }
    end
  end

  def primary_roles
    @primary_roles ||= begin
      primary_roles = personal_roles.select { |personal_role| personal_role.primary == true }
      # if >1 then cannot judge which is the 'best' role
      if primary_roles == [] && straight_roles.size == 1
        straight_roles
      end
    end
  end

  def primary_role
    primary_roles&.first
  end

  def person?
    !(animal? or thing? or group? or place?)
  end

  def animal?
    roles.find(&:animal?)
  end

  def thing?
    roles.find(&:thing?)
  end

  def group?
    roles.find(&:group?)
  end

  def place?
    roles.find(&:place?)
  end

  def type
    return "man" if person? && male?
    return "woman" if person? && female?
    return "person" if person?
    return "animal" if animal?
    return "thing" if thing?
    return "group" if group?
    return "place" if place?
    return "?"
  end

  def born_in
    born_on&.year
  end

  def died_in
    died_on&.year
  end

  def dates
    dates = ""
    if born_in
      dates = "("
      dates << born_in.to_s
      if died_in
        dates << "-#{died_in.to_s}" if (born_in != died_in)
      else
        dates << (alive? ? "-present" : "-?")
      end
      dates << ")"
    elsif died_in
      dates = "(d.#{died_in.to_s})"
    end
  end

  def born_at
    birth_connection&.location
  end

  def died_at
    death_connection&.location
  end

  def dead?
    died_in || (person? || animal?) && born_in && born_in < 1910
  end

  def alive?
    !dead?
  end

  def existence_word
    alive? ? "is" : "was"
  end

  def age
    circa = died_on && born_on && born_on.month == 1 && born_on.day == 1 && died_on.month == 1 && died_on.day == 1
    return "c. #{(died_on.year - born_on.year)}" if circa
    if died_on && born_on
      a = died_on.year - born_on.year
      a = a - 1 if (
        born_on.month > died_on.month or
        (born_on.month >= died_on.month and born_on.day > died_on.day)
      )
      return "#{a}"
    end
    return Time.now.year - born_in if born_in && inanimate_object?
    return Time.now.year - born_in if born_in && born_in > 1910
    "unknown"
  end

  def age_in(year)
    year - born_in if born_in
  end

  def fill_wikidata_id
    unless wikidata_id&.match /Q\d*$/
      t = name
      t = "#{name} (#{born_in}-#{died_in})" if born_in && died_in
      self.wikidata_id = Wikidata.qcode(t)
    end
  end

  def wikidata_url
    "https://www.wikidata.org/wiki/#{wikidata_id}" if wikidata_id && !wikidata_id&.blank? && wikidata_id != "Q"
  end

  def wikipedia_url
    Wikidata.new(wikidata_id).en_wikipedia_url
  end

  def dbpedia_uri
    wikipedia_url&.gsub("en.wikipedia.org/wiki","dbpedia.org/resource")&.gsub("https","http")
  end

  def dbpedia_abstract
    return nil if !dbpedia_json
    begin
    dbpedia_json["#{dbpedia_uri}"]['http://dbpedia.org/ontology/abstract'].find {|abstract| abstract['lang']=='en'}['value']
    rescue
    end
  end

  def dbpedia_depiction
    return nil if !dbpedia_json
    begin
    dbpedia_json["#{dbpedia_uri}"]['http://xmlns.com/foaf/0.1/depiction'].first['value']
    rescue
    end
  end

  def dbpedia_json
    # call DBpedia and cache the response
    return @dbpedia_json if defined? @dbpedia_json
    @dbpedia_json = nil
    return @dbpedia_json if dbpedia_uri.blank?
    @dbpedia_json = begin
      api = "#{dbpedia_uri.gsub("resource","data")}.json"
      response = open(api)
      resp = response.read
      JSON.parse(resp)
    rescue
    end
  end

  def name_and_dates
     "#{full_name} #{dates.to_s}"
  end

  def surname
    name[name.downcase.rindex(" #{surname_starts_with.downcase}") ? name.downcase.rindex(" #{surname_starts_with.downcase}") + 1: 0, name.size]
  end

  def default_thumbnail_url
    "/assets/NoPersonSqr.png"
  end

  def current_roles
    current_roles = []
    personal_roles.each do |pr|
      current_roles << pr.role if pr.current?
    end
    current_roles.sort! { |b,a| a.priority && b.priority ? a.priority <=> b.priority : (a.priority ? 1 : -1) }
    current_roles
  end

  def title
    title = ""
    current_roles.each do |role|
      if !role.prefix.blank?
        # NB a clergyman or Commonwealth citizen does not get called 'Sir'
        title << "#{role.prefix} " if !title.include?(role.prefix) && !(role.prefix == "Sir" && clergy?)
      elsif role.used_as_a_prefix? and !title.include?(role.display_name)
        title << "#{role.display_name} "
      end
    end
    title.strip
  end

  def titled?
    title != ""
  end

  def clergy?
    roles.any? { |role| role.role_type=="clergy" }
  end

  def letters
    letters = ""
    current_roles.each do |role|
      letters << " #{role.suffix}" if !role.suffix.blank? && !letters.include?(role.suffix)
    end
    letters.strip
  end

  def full_name
    "#{title} #{name} #{letters}".strip
  end

  def names
    nameparts = name.split(" ")
    firstname = nameparts.first
    firstinitial = nameparts.second ? "#{firstname[0,1]}." : ""
    secondname = nameparts.third ? nameparts.second : ""
    secondinitial = nameparts.third ? "#{secondname[0,1]}." : ""
    middlenames = nameparts.length > 2 ? nameparts.from(1).to(nameparts.from(1).length - 2) : []
    middleinitials = ""
    middlenames.each_with_index do |name, index|
      middleinitials << " " if index > 0
      middleinitials << "#{name.to_s[0,1]}."
    end
    lastname = nameparts.last
    names = []
    names << full_name # Joseph Aloysius Hansom
    names << "#{title} #{name}" if titled? # Sir Joseph Aloysius Hansom
    names += self.aka # Boz, Charlie Cheese, and Crackers
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
    names << "#{title} #{firstname} #{lastname}" if nameparts.length > 2 && titled?# Sir Joseph Hansom
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
      return relationship.related_person if (relationship.role.role_type=="child") && relationship.related_person!=nil && relationship.related_person.male?
    end
    nil
  end

  def mother
    relationships.each do |relationship|
      return relationship.related_person if (relationship.role.role_type=="child") && relationship.related_person!=nil && relationship.related_person.female?
    end
    nil
  end

  def children
    issue = []
    relationships.each do |relationship|
      issue << relationship.related_person if relationship.role.role_type=="parent"
    end
    issue.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def has_children?
    children.size > 0
  end

  def siblings
    siblings = []
    if father != nil
      father.children.each { |child| siblings << child if child != self }
    end
    if mother != nil
      mother.children.each { |child| siblings << child if child != self }
    end
    siblings.uniq.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def spouses
    people = []
    relationships.each do |relationship|
      people << relationship.related_person if relationship.role.role_type == "spouse"
    end
    people #.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def spousal_relationships
    spousal_relationships = []
    relationships.each do |relationship|
      spousal_relationships << relationship if relationship.role.role_type == "spouse"
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

  def has_family?
    family_relationships.size > 0
  end

  def creation_word
    return "from" if thing?
    return "formed in" if group?
    return "built in" if place?
    "born in"
  end

  def destruction_word
    return "until" if thing?
    return "ended in" if group?
    return "closed in" if place?
    "died in"
  end

  def inanimate_object?
    thing? || group? || place?
  end

  def personal_pronoun
    return "it" if inanimate_object?
    return "he" if male?
    return "she" if female?
    "he/she"
  end

  def male?
    !self.female?
  end

  def female?
    if self.gender == 'u'
      self.gender = 'f' if roles.any?{|role| role.female?}
      self.gender = 'f' if self.name.start_with?(
      "Abigail","Adelaide","Adele","Ada","Agnes","Alice","Alison","Amalie","Amelia","Anastasia","Anna","Anne","Annie","Antoinette",
      "Beatriz","Bertha","Betty",
      "Caroline","Cäcilie","Charlotte","Clara","Constance",
      "Daisy","Deborah","Diana","Dolly","Doris","Dorothea","Dorothy",
      "Edith","Elfriede","Elisabeth","Elise","Elizabeth","Ella","Ellen","Elly","Elsbeth","Elsa","Else","Emilie","Emily","Emma","Erika","Erna","Ernestine","Eva",
      "Fanny","Flora","Florence","Franziska","Frida","Frieda",
      "Georgia","Georgina","Gerda","Gertrud","Gladys","Grace","Greta","Grete",
      "Hanna","Hattie","Hazel","Helen","Helene","Henrietta","Henriette","Herta","Hertha","Hilde","Hildegard",
      "Ida","Ilse","Irene","Irma",
      "Jane","Janet","Jacqueline","Jeanne","Jenny","Jennifer","Johanna","Josephine","Judith","Julia","Julie",
      "Kate","Käte","Käthe","Kathleen","Klara",
      "Laura","Letitia","Lidia","Lina","Liz","Lotte","Louise","Louisa","Lucie","Lucy","Luise",
      "Mabel","Mala","Margaret","Margery","Margot","Maria","Marianne","Marie","Martha","Mary","Mathilde","May","Mercy","Meta","Minna","Monica","Monika",
      "Nancy, Nelly",
      "Olga",
      "Paloma","Paula","Pauline","Peggy","Priscilla",
      "Rachel","Regina","Roberta","Rosa","Rose","Ruth",
      "Sally","Sarah","Sara","Selma","Shelley","Sophie","Susan","Susanna",
      "Toni","Therese",
      "Ursula",
      "Vera","Victoria","Violet","Virginia",
      "Wilhelmina","Winifred")
      self.gender = 'm' if self.name.start_with?("Reginald")
    end
    self.gender == 'f'
  end

  def sex
    return "female" if female?
    return "object" if inanimate_object?
    "male"
  end

  def possessive
    return "its" if inanimate_object?
    return "her" if self.female?
    return "his" if self.male?
    "his/her"
  end

  def is_related_to?(person)
    relationships.each do |r|
      return true if r.related_person == person
    end
    false
  end

  def find_a_grave_url
    "http://www.findagrave.com/cgi-bin/fg.cgi?page=gr&GRid=#{self.find_a_grave_id}" if find_a_grave_id && !find_a_grave_id&.blank?
  end

  def ancestry_url
    "http://www.ancestry.co.uk/genealogy/records/#{self.ancestry_id}" if ancestry_id && !ancestry_id&.blank?
  end

  def uri
    "http://openplaques.org#{Rails.application.routes.url_helpers.person_path(self, format: :json)}"
  end

  def machine_tag
    "openplaques:subject:id=#{id}"
  end

  def to_s
    self.name
  end

  def as_json(options=nil)
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
                only: [], methods: [:uri, :full_name]
              }
            }
          }
        },
        methods: [
          :uri,
          :name_and_dates,
          :full_name,
          :surname,
          :born_in,
          :died_in,
          :type,
          :sex,
          :primary_role,
          :wikidata_id,
          :wikipedia_url,
          :dbpedia_uri,
          :find_a_grave_url
        ]
      }
    end
    super(options)
  end

#  protected

    def update_index
      self.index = self.name[0,1].downcase
      if self.surname_starts_with.blank?
        self.surname_starts_with = self.name[self.name.rindex(" ") ? self.name.rindex(" ") + 1 : 0,1].downcase
      end
      self.surname_starts_with.downcase!
    end

    def unaccented_name
      name.tr("ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
"AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")
    end

    def accented_name?
      return name != unaccented_name
    end

    def aka_accented_name
      if accented_name? && !aka.include?(unaccented_name)
        self.aka_will_change!
        self.aka.push(unaccented_name)
      end
    end

    def depiction_from_dbpedia
      if !self.main_photo && dbpedia_depiction
        begin
          photo = Photo.new(url: dbpedia_depiction, person: self)
          photo.wikimedia_data
          photo.save
        rescue
        end
      end
    end

end
