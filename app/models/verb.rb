# A verb that connects a person with a location, eg 'lived', 'worked' or 'played'.
#
# === Attributes
# * +name+ - The name of the verb, in past tense, eg 'lived'.
# * +personal_connections_count+ - cached count of people connected to this verb
#
# === Associations
# * +personal_connections+ - The personal connections (joining model) which connect with this verb.
#
# === Indirect Associations
# * +people+ - The people associated with this verb.
class Verb < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :personal_connections
  has_many :people, :through => :personal_connections
  scope :name_starts_with, lambda {|term| where(["lower(name) LIKE ?", term.downcase + "%"]) }
  scope :name_contains, lambda {|term| where(["lower(name) LIKE ?", "%" + term.downcase + "%"]) }

  def self.common
    [Verb.find_by_name("was born"),Verb.find_by_name("lived"),Verb.find_by_name("died")].compact
  end

  def to_param
    "#{name.gsub('.', '_').gsub(' ', '_')}"
  end

  def to_s
    return name
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.verb_path(self, :format => :json)
  end

  def as_json(options=nil)
    if options && options[:only]
    else
      options = {
        :only => [:name],
        :include => {
          :people => {:only => [:name], :methods => [:uri]}
        },
        :methods => [:uri]
      }
    end
    super(options)
  end
  
end
