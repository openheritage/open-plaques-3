require 'rubygems'
require 'open-uri'
#require 'rdf/ntriples'

# This class represents a human who has been commemorated on a plaque.
# === Attributes
# * +name+ - The common full name of the person.
# * +wikipedia_url+ - An override link to the person's Wikipedia page (if they have one and it isn't linked to via their name).
# * +dbpedia_uri+ - A link to the DBpedia resource representing the person (if one exists).
# * +born_on+ - The date on which the person was born. Optional.
# * +died_on+ - The date on which the person died. Optional.
# * +born_on_is_circa+ - True or False. Whether the +born_on+ date is 'circa' or not. Optional.
# * +died_on_is_circa+ - True or False. Whether the +died_on+ date is 'circa' or not. Optional.
# * +personal_connections_count+ - cached count of associations with plaques, i.e. places and times
# * +personal_roles_count+ - cached count of roles
#
# === Associations
# * PersonalRoles - link to a role and potentially another person (e.g. by being their husband)
# * PersonalConnections - link to a time and place via a mention on a plaque
# * MainPhoto - image showing the person (via photos)
#
# === Indirect Associations
# * Plaques - plaques on which this person is commemorated.
# * Roles - roles associated with this person (eg 'carpenter').

class Person < ActiveRecord::Base

  validates_presence_of :name

  has_many :personal_roles
  has_many :personal_connections #, -> { order('started_at asc') }
  has_many :roles, :through => :personal_roles
  has_many :plaques, :through => :personal_connections #, :uniq => true
  has_one :birth_connection, -> { where('verb_id in (8,504)') }, :class_name => "PersonalConnection"
  has_one :death_connection, -> { where('verb_id in (3,49,161,1108)') }, :class_name => "PersonalConnection"
  has_one :main_photo, :class_name => "Photo"

  attr_accessor :abstract, :comment # dbpedia fields

  before_save :update_index

  scope :no_role, -> { where(personal_roles_count: [nil,0]) }
  scope :no_dates, -> { where('born_on IS NULL and died_on IS NULL') }

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

  def born_at
    birth_connection.location if (birth_connection)
  end

  def died_at
    death_connection.location if (death_connection)
  end

  def dead?
    return true if died_in
    return true if (person? || animal?) && born_in && born_in < 1900
    false
  end

  def alive?
    !dead?
  end
  
  def existence_word
    return "is" if alive?
    "was"
  end

  def age
    return died_in - born_in if died_in && born_in
    return Time.now.year - born_in if born_in && thing?
    return Time.now.year - born_in if born_in && born_in > 1900
    "unknown"
   end

  def age_in(year)
    return year - born_in if born_in
  end

  # note that the Wikipedia url is constructed from the person's name
  # unless it is overridden by data in the wikipedia_url field
  # or the wikipedia_url field is set to blank to indicate that there
  # is no Wikipedia record
  def default_wikipedia_url
    return wikipedia_url.gsub("http:","https:") if wikipedia_url && wikipedia_url > ""
    untitled_name = name.gsub("Canon ","").gsub("Captain ","").gsub("Cardinal ","").gsub("Dame ","").gsub("Dr ","").gsub("Lord ","").gsub("Sir ","").strip.gsub(/ /,"_")
    "https://en.wikipedia.org/wiki/"+untitled_name
  end

  def default_dbpedia_uri
    return default_wikipedia_url.gsub("en.wikipedia.org/wiki","dbpedia.org/resource").gsub("https","http")
  end

  def dbpedia_ntriples_uri
    default_dbpedia_uri.gsub("resource","data") + ".ntriples"
  end

  def name_and_dates
    (name + " " + dates)
  end

  def name_and_raw_dates
    (name + " " + raw_dates)
  end

  def dates
    r = ""
    r += "(" if born_on || died_on
    r += creation_word + " " if born_on && !died_on
    r += born_on.year.to_s if born_on
    r += "-" if born_on && died_on
    r += destruction_word + " " if !born_on && died_on
    r += died_on.year.to_s if died_on
    r += ")" if born_on || died_on
    return r
  end

  def raw_dates
    r = ""
    r += "(" if born_on || died_on
    r += born_on.year.to_s if born_on
    r += "-" if born_on && died_on
    r += died_on.year.to_s if died_on
    r += ")" if born_on || died_on
    return r
  end

  def surname
    self.name[self.name.downcase.rindex(" " + self.surname_starts_with.downcase) ? self.name.downcase.rindex(" " + self.surname_starts_with.downcase) + 1: 0,self.name.size]
  end

  def default_thumbnail_url
    return "/assets/NoPersonSqr.png"
  end

  def populate_from_dbpedia
    begin
      graph = RDF::Graph.load(self.dbpedia_ntriples_uri)
      query = RDF::Query.new({
        :person => {
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
      current_roles << pr.role if pr.ended_at == nil or pr.ended_at == ''
    end
    current_roles
  end
  
  def title
    title = ""
    current_roles.each do |role|
      # a clergyman or Commonwealth citizen does not get called 'Sir'
      if !role.prefix.blank?
        title += role.prefix + " " if !title.include?(role.prefix)
      elsif role.confers_honourific_title? && !clergy? && male? && !title.include?("Sir ")
        title += "Sir "
      elsif role.confers_honourific_title? && !clergy? && female? && !title.include?("Lady ")
        title += "Lady "
#      elsif ("DBE" == role.abbreviation or "GBE" == role.abbreviation or "DCVO" == role.abbreviation) && !title.include?("Dame ")
#        title += "Dame "
      elsif role.used_as_a_prefix? and !title.include?(role.display_name)
        title += role.display_name + " " 
      end
    end
    title.strip
  end

  def titled?
    title != nil
  end
  
  def clergy?
    roles.any? { |role| role.role_type=="clergy"}
  end
  
  def letters
    letters = ""
    current_roles.each do |role|
      letters += " " + role.suffix if role.suffix
    end
    letters.strip
  end
  
  def full_name
    fullname = ""
    fullname += title + " " # if titled?
    fullname += name 
    fullname += " " + letters if !letters.blank?
    fullname.strip
  end
  
  def parents
    parents = []
    relationships.each do |relationship|
      parents << relationship.related_person if (relationship.role.name=="son" or relationship.role.name=="daughter") && relationship.related_person!=nil
    end
    parents
    parents.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end

  def children
    issue = []
    relationships.each do |relationship|
      issue << relationship.related_person if relationship.role.name=="father" or relationship.role.name=="mother"
    end
    issue.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }
  end
  
  def siblings
    # should probably work this out from the parents
    siblings = []
    relationships.each do |relationship|
      siblings << relationship.related_person if relationship.role.name=="brother" or relationship.role.name=="sister" or relationship.role.name=="half-brother" or relationship.role.name=="half-sister"
    end
    siblings.sort! { |a,b| a.born_on ? a.born_on : 0 <=> b.born_on ? b.born_on : 0 }   
  end
  
  def spousal_relationships
    spouses = []
    relationships.each do |relationship|
      spouses << relationship if relationship.role.name=="wife" or relationship.role.name=="husband"
    end
    spouses 
  end
  
  def non_family_relationships
    non_family = []
    relationships.each{|relationship|
      non_family << relationship if relationship.role.name!="husband" and relationship.role.name!="wife" and relationship.role.name!="brother" and relationship.role.name!="sister" and relationship.role.name!="half-brother" and relationship.role.name!="half-sister" and relationship.role.name!="father" and relationship.role.name!="mother" and relationship.role.name!="son" and relationship.role.name!="daughter"
    }
    non_family 
  end
  
  def creation_word
    return "from" if (self.thing?)
    return "formed in" if (self.group?)
    return "built in" if (self.place?)
    "born in"
  end
  
  def destruction_word
    return "until" if self.thing?
    return "ended in" if self.group?
    return "closed in" if self.place?
    "died in"
  end
  
  def personal_pronoun
    return "it" if (self.thing? || self.group? || self.place?)
    return "he" if self.male?
    return "she" if self.female?
    "he/she"
  end

  def male?
    !self.female?
  end

  def female?
    return true if roles.any?{|role| role.female?}
    return true if self.name.start_with?(
      "Abigail","Adelaide","Ada","Agnes","Alice","Alison","Amelia","Anastasia","Anna","Anne","Annie","Antoinette",
      "Beatriz",
      "Caroline","Charlotte","Clara","Constance",
      "Deborah","Diana","Dolly","Doris","Dorothea",
      "Elizabeth","Ellen","Emma",
      "Florence",
      "Georgia","Georgina","Gladys",
      "Hattie",
      "Jane","Janet","Jacqueline","Jeanne","Julia",
      "Kate","Kathleen",
      "Letitia", "Lidia","Louisa",
      "Mabel","Margaret","Margery","Marianne","Mary","May","Mercy",
      "Nancy, Nelly",
      "Paloma","Priscilla",
      "Rachel","Roberta","Rosa","Rose",
      "Sally","Susanna",
      "Ursula",
      "Victoria","Violet","Virginia",
      "Wilhelmina","Winifred")
    false
  end

  def sex
    return "female" if female?
    return "object" if (self.thing? || self.group? || self.place?)
    "male"
  end
  
  def possessive
    return "its" if (self.thing? || self.group? || self.place?)
    return "her" if self.female?
    return "his" if self.male?
    "his/her"
  end
    
  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.person_path(self, :format => :json)
  end
    
  def to_s
    self.name
  end

  def as_json(options={})
    super(
      :only => [],
      :include => {
#        :main_photo => {:only => [], :methods => :uri},
        :personal_roles => {
          :only => [], 
          :include => {
            :role => {:only => :name},
            :related_person => {
              :only => [], :methods => [:uri, :full_name]
            }
          }, 
          :methods => [:uri]
        }
 #       :personal_connections  => {
 #         :only => [],
 #         :include => {
 #           :verb => {:only => :name},
 #           :location => {
 #             :only => :name, :include => {:area => {:only => :name, :methods => :uri, :include => {:country => {:only => [:name, :alpha2]}}}}},
 #           :plaque => {
 #             :only => [], 
 #             :methods => :uri
 #           }
 #         }, 
 #         :methods => [:uri, :from, :to]
 #       }
      },
      :methods => [
        :uri,
        :name_and_dates,
        :full_name,
        :surname,
        :born_in,
#        :born_at,
        :died_in,
#        :died_at,
        :type,
        :sex,
        :default_wikipedia_url,
        :default_dbpedia_uri
      ]
    )
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
