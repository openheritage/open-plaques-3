
# This class represents a commemoration of a Person on a commemorative Plaque, and acts as a
# convenient 'join' between the two.
# === Associations
# * Plaque - the plaque on which this commemoration occurs.
# * Person - the person referenced in the commemoration
# * Location - the location referenced in the commemoration (usually the same location as where the plaque is physically located, but this can be different in the case of plaques which commemorate a 'nearby' site or event.).
# * Verb - the verb used to describe the association (eg 'lived').
class PersonalConnection < ActiveRecord::Base

  validates_presence_of :verb_id, :person_id, :location_id, :plaque_id

  belongs_to :verb, :counter_cache => true
  belongs_to :person, :counter_cache => true
  belongs_to :location, :counter_cache => true
  belongs_to :plaque, :counter_cache => true

  attr_accessor :other_verb_id

  def from
    if (verb.id == 8 or verb.id == 504)
      return person.born_in.to_s
    end
    if (verb.id == 3 or verb.id == 49 or verb.id == 161 or verb.id == 288 or verb.id == 566 or verb.id == 1108)
      return person.died_in.to_s
    end
    started_at ? started_at.year.to_s : ""
  end

  def to
    if (verb.id == 8 or verb.id == 504)
      return person.born_in.to_s
    end
    if (verb.id == 3 or verb.id == 49 or verb.id == 161 or verb.id == 288 or verb.id == 566 or verb.id == 1108)
      return person.died_in.to_s
    end
    ended_at ? ended_at.year.to_s : ""
  end

end
