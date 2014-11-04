# A verb that connects a person with a location, eg 'lived', 'worked' or 'played'.
#
# === Attributes
# * +name+ - The name of the verb, in past tense, eg 'lived'.
#
# === Associations
# * +plaques+ - The plaques on which this verb is used.
# * +people+ - The people associated with this verb.
# * +locations+ - The locations associated with this verb.
# * +personal_connections+ - The personal connections (joining model) which connect with this verb.
class Verb < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :personal_connections
  has_many :people, :through => :personal_connections

  def self.common
    [Verb.find_by_name("was born"),Verb.find_by_name("born"),Verb.find_by_name("lived"),Verb.find_by_name("died")].compact!
  end

  def to_param
    "#{name.gsub('.', '_').gsub(' ', '_')}"
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.verb_path(self, :format => :json)
  end

  def as_json(options={})
    # this ignores the user's options
    super(:only => [:name],
      :include => {
        :people => {:only => [:name], :methods => [:uri]}
      },
      :methods => [:uri]
    )
  end
end
