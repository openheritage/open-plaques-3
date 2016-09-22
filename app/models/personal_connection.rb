# A commemoration of a subject on a plaque. This acts as a 'join' between the two.
# === Attributes
# * +started_at+ - when the person started doing what they did at the place
# * +ended_at+ - when the person stopped doing what they did at the place
class PersonalConnection < ActiveRecord::Base

  belongs_to :person, counter_cache: true
  belongs_to :plaque, counter_cache: true
  belongs_to :verb, counter_cache: true

  attr_accessor :other_verb_id

  validates_presence_of :verb_id, :person_id, :plaque_id

  def from
    year = started_at ? started_at.year.to_s : ""
    year = person.born_in.to_s if (verb.id == 8 or verb.id == 504)
    year = person.died_in.to_s if (verb.id == 3 or verb.id == 49 or verb.id == 161 or verb.id == 288 or verb.id == 566 or verb.id == 1108)
    year
  end

  def to
    year = ended_at ? ended_at.year.to_s : ""
    year = person.born_in.to_s if (verb.id == 8 or verb.id == 504)
    year = person.died_in.to_s if (verb.id == 3 or verb.id == 49 or verb.id == 161 or verb.id == 288 or verb.id == 566 or verb.id == 1108)
    year
  end

  def full_address
    plaque.full_address
  end

  def single_year?
    from == to
  end

end
