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
# * +wikipedia_paras+ - which paragraphs in Wikipedia to use as description
# * +surname_starts_with+ - letter to index this person on
# * +introduction+ -
# * +gender+ - (u)nkown, (n)ot applicable, (m)ale, (f)emale
# * +aka+ - array of names that person is also known as
# * +find_a_grave_id+ - link to Find A Grave web site
# * +ancestry_id+ - link to Ancestry.com web site
require 'rubygems'
require 'open-uri'
#require 'rdf/ntriples'

class Person < ActiveRecord::Base

  has_many :personal_roles
  has_many :personal_connections
  has_many :roles, through: :personal_roles
  has_many :plaques, through: :personal_connections
  has_one :birth_connection, -> { where('verb_id in (8,504)') }, class_name: "PersonalConnection"
  has_one :death_connection, -> { where('verb_id in (3,49,161,1108)') }, class_name: "PersonalConnection"
  has_one :main_photo, class_name: "Photo"

  attr_accessor :abstract, :comment # dbpedia fields

  validates_presence_of :name
  before_save :update_index
  scope :roled, -> { where("personal_roles_count > 0").order("id DESC") }
  scope :unroled, -> { where(personal_roles_count: [nil,0]) }
  scope :dated, -> { where("born_on IS NOT NULL or died_on IS NOT NULL") }
  scope :undated, -> { where("born_on IS NULL and died_on IS NULL") }
  scope :photographed, joins(:main_photo)
  scope :unphotographed, -> { where("id not in (select person_id from photos)").order("id DESC") }
  scope :connected, -> { where("personal_connections_count > 0").order("id DESC") }
  scope :unconnected, -> { where(personal_connections_count: [nil,0]).order("id DESC") }
  scope :name_starts_with, lambda {|term| where(["lower(name) LIKE ?", term.downcase + "%"]) }
  scope :name_contains, lambda {|term| where(["lower(name) LIKE ?", "%" + term.downcase + "%"]) }

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
      straight_roles = personal_roles.select do |personal_role|
        personal_role.related_person_id == nil
      end
      straight_roles.sort { |a,b| a.started_at.to_s <=> b.started_at.to_s }
    end
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
    born_on.year if born_on
  end

  def died_in
    died_on.year if died_on
  end

  def dates
    dates = ""
    if born_in
      dates = "("
      dates += born_in.to_s
      if died_in
        dates += "-" + died_in.to_s if (born_in != died_in)
      else
        dates += alive? ? "-present" : "-?"
      end
      dates += ")"
    elsif died_in
      dates = '(d.' + died_in.to_s + ')'
    end
  end

  def born_at
    birth_connection.location if birth_connection
  end

  def died_at
    death_connection.location if death_connection
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
    circa = died_on && born_on && born_on.month == 1 && born_on.day == 1 && died_on.month == 1 && died_on.day == 1 ? 'c.' : ''
    return circa + (died_in - born_in).to_s if died_on && born_on
    return Time.now.year - born_in if born_in && inanimate_object?
    return Time.now.year - born_in if born_in && born_in > 1910
    "unknown"
  end

  def age_in(year)
    year - born_in if born_in
  end

  # note that the Wikipedia url is constructed from the person's name
  # unless it is overridden by data in the wikipedia_url field
  # or the wikipedia_url field is set to blank to indicate that there
  # is no Wikipedia record
  def default_wikipedia_url
    return wikipedia_url.gsub("http:","https:") if wikipedia_url && wikipedia_url > ""
    untitled_name = name.gsub("Canon ","").gsub("Captain ","").gsub("Cardinal ","").gsub("Dame ","").gsub("Dr ","").gsub('Lord ','').gsub('Sir ','').strip.tr(' ','_')
    "https://en.wikipedia.org/wiki/"+untitled_name
  end

  def default_dbpedia_uri
    default_wikipedia_url.gsub("en.wikipedia.org/wiki","dbpedia.org/resource").gsub("https","http")
  end

  def dbpedia_ntriples_uri
    default_dbpedia_uri.gsub("resource","data") + ".ntriples"
  end

  def name_and_dates
    name + " " + dates.to_s
  end

  def surname
    self.name[self.name.downcase.rindex(" " + self.surname_starts_with.downcase) ? self.name.downcase.rindex(" " + self.surname_starts_with.downcase) + 1: 0,self.name.size]
  end

  def default_thumbnail_url
    "/assets/NoPersonSqr.png"
  end

  def populate_from_dbpedia
    begin
      graph = RDF::Graph.load(self.dbpedia_ntriples_uri)
      query = RDF::Query.new({
        person: {
          RDF::URI("http://dbpedia.org/ontology/birthDate") => :birthDate,
          RDF::URI("http://dbpedia.org/ontology/deathDate") => :deathDate,
          RDF::URI("http://xmlns.com/foaf/0.1/depiction") => :depiction,
          RDF::URI("http://dbpedia.org/ontology/abstract") => :abstract,
          RDF::URI("http://www.w3.org/2000/01/rdf-schema#comment") => :comment,
        }
      })
      query.execute(graph).filter { |solution| solution.comment.language == :en }.each do |solution|
        self.depiction = solution.depiction
        # need to filter abstract/comment with something like http://rdf.rubyforge.org/RDF/Query/Solutions.html
        self.abstract = solution.abstract
        self.comment = solution.comment
      end
    rescue
    end
  end

  def current_roles
    current_roles = []
    personal_roles.each do |pr|
      current_roles << pr.role if pr.role.prefix == "King" or pr.role.prefix == "Queen" || pr.ended_at == nil or pr.ended_at == '' or (pr.ended_at && pr.ended_at.year.to_s == died_on.to_s)
    end
    current_roles
  end

  def title
    title = ""
    current_roles.each do |role|
      if !role.prefix.blank?
        # NB a clergyman or Commonwealth citizen does not get called 'Sir'
        title += "#{role.prefix} " if !title.include?(role.prefix) && !(role.prefix == "Sir" && clergy?)
      elsif role.used_as_a_prefix? and !title.include?(role.display_name)
        title += "#{role.display_name} "
      end
    end
    title.strip
  end

  def titled?
    title != ""
  end

  def clergy?
    roles.any? { |role| role.role_type=="clergy"}
  end

  def letters
    letters = ""
    current_roles.each do |role|
      letters += " " + role.suffix if !role.suffix.blank?
    end
    letters.strip
  end

  def full_name
    fullname = title + " " + name + " " + letters
    fullname.strip
  end

  def names
    nameparts = name.split(" ")
    firstname = nameparts.first
    firstinitial = nameparts.second ? firstname[0,1] + "." : ""
    secondname = nameparts.third ? nameparts.second : ""
    secondinitial = nameparts.third ? secondname[0,1] + "." : ""
    middlenames = nameparts.length > 2 ? nameparts.from(1).to(nameparts.from(1).length - 2) : []
    middleinitials = ""
    middlenames.each_with_index do |name, index|
      middleinitials += " " if index > 0
      middleinitials += name.to_s[0,1] + "."
    end
    lastname = nameparts.last
    names = []
    names << full_name # Sir Joseph Aloysius Hansom
    names << title + " " + name if titled? # Dame Laura Knight [DBE]
    names += self.aka # Boz, Charlie Cheese, and Crackers
    names << title + " " + firstinitial + " " + middleinitials + " " + lastname if titled? && nameparts.length > 2
    names << title + " " + firstinitial + " " + lastname if titled? && nameparts.length > 1
    names << name if name != full_name # Joseph Aloysius Hansom
    if name.include? ',' # George Inn, Barcombe
      names << name.split(/,/).first
      return names
    end
    names << title + " " + name.split(/ of /).first if name.include?(' of ') && titled? # King Charles II [of England]
    names << name.split(/ of /).first if name.include? ' of ' # [King] Charles II [of England]
    names << firstname + " " + middleinitials + " " + lastname if nameparts.length > 2 # Joseph A[loysius]. R[obert]. Hansom
    names << firstinitial + " " + middleinitials + " " + lastname if nameparts.length > 2 # J. A. R. Hansom
    names << firstname + " " + nameparts.second + " " + lastname if nameparts.length > 2 # Joseph Aaron Hansom
    names << firstname + " " + secondinitial + " " + lastname if nameparts.length > 2 # Joseph A. Hansom
    names << firstinitial + " " + secondname + " " + lastname if nameparts.length > 2 # J. Aaron Hansom
    names << firstname + " " + lastname if nameparts.length > 2 # Joseph Hansom
    names << firstinitial + " " + lastname  if nameparts.length > 1 # J. Hansom
    names << title + " " + lastname if titled? # Lord Carlisle
    names << title + " " + firstname if titled? # Sir William
    names << firstname if nameparts.length > 1 # Charles
    names << lastname if nameparts.length > 1 # Kitchener
    names.uniq
  end

  def father
    relationships.each do |relationship|
      return relationship.related_person if (relationship.role.name=="son" or relationship.role.name=="daughter") && relationship.related_person!=nil && relationship.related_person.male?
    end
    nil
  end

  def mother
    relationships.each do |relationship|
      return relationship.related_person if (relationship.role.name=="son" or relationship.role.name=="daughter") && relationship.related_person!=nil && relationship.related_person.female?
    end
    nil
  end

  def children
    issue = []
    relationships.each do |relationship|
      issue << relationship.related_person if relationship.role.name=="father" or relationship.role.name=="mother"
    end
    issue.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def has_children?
    children.size > 0
  end

  def siblings
    siblings = []
    if father != nil
      father.children.each do |child|
        siblings << child if child != self
      end
    end
    if mother != nil
      mother.children.each do |child|
        siblings << child if child != self
      end
    end
    siblings.uniq.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def spouses
    people = []
    relationships.each do |relationship|
      people << relationship.related_person if relationship.role.name=="wife" or relationship.role.name=="husband"
    end
    people #.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def spousal_relationships
    spousal_relationships = []
    relationships.each do |relationship|
      spousal_relationships << relationship if relationship.role.name=="wife" or relationship.role.name=="husband"
    end
    spousal_relationships
  end

  def non_family_relationships
    non_family = []
    relationships.each{|relationship|
      non_family << relationship if relationship.role.name!="husband" and relationship.role.name!="wife" and relationship.role.name!="brother" and relationship.role.name!="sister" and relationship.role.name!="half-brother" and relationship.role.name!="half-sister" and relationship.role.name!="father" and relationship.role.name!="mother" and relationship.role.name!="son" and relationship.role.name!="daughter"
    }
    non_family
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
      "Daisy","Deborah","Diana","Dolly","Doris","Dorothea",
      "Edith","Elfriede","Elisabeth","Elise","Elizabeth","Ella","Ellen","Elly","Elsbeth","Elsa","Else","Emilie","Emily","Emma","Erika","Erna","Ernestine","Eva",
      "Fanny","Flora","Florence","Franziska","Frida","Frieda",
      "Georgia","Georgina","Gerda","Gertrud","Gladys","Greta","Grete",
      "Hanna","Hattie","Hazel","Helen","Helene","Henrietta","Henriette","Herta","Hertha","Hilde","Hildegard",
      "Ida","Ilse","Irene","Irma",
      "Jane","Janet","Jacqueline","Jeanne","Jenny","Jennifer","Johanna","Josephine","Julia","Julie",
      "Kate","Käte","Käthe","Kathleen","Klara",
      "Laura","Letitia","Lidia","Lina","Liz","Lotte","Louisa","Lucie","Lucy","Luise",
      "Mabel","Mala","Margaret","Margery","Margot","Marianne","Marie","Martha","Mary","Mathilde","May","Mercy","Meta","Minna","Monica","Monika",
      "Nancy, Nelly",
      "Olga",
      "Paloma","Paula","Pauline","Priscilla",
      "Rachel","Regina","Roberta","Rosa","Rose","Ruth",
      "Sally","Sarah","Sara","Selma","Shelley","Sophie","Susan","Susanna",
      "Toni","Therese",
      "Ursula",
      "Vera","Victoria","Violet","Virginia",
      "Wilhelmina","Winifred")
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
    self.find_a_grave_id ? "http://www.findagrave.com/cgi-bin/fg.cgi?page=gr&GRid=" + self.find_a_grave_id : null
  end

  def ancestry_url
    self.ancestry_id ? "http://www.ancestry.co.uk/genealogy/records/" + self.ancestry_id : null
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.person_path(self, format: :json)
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
              role: {only: :name},
              related_person: {
                only: [], methods: [:uri, :full_name]
              }
            },
            methods: [:uri]
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
          :default_wikipedia_url,
          :default_dbpedia_uri
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

end
