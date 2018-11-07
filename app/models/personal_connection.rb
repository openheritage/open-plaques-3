# A commemoration of a subject on a plaque. This acts as a 'join' between the two.
# === Attributes
# * +ended_at+ - when the subject stopped doing what they did at the place
# * +started_at+ - when the subject started doing what they did at the place
# * +plaque_connections_count+ - Cached count of plaques
class PersonalConnection < ApplicationRecord
  belongs_to :person, counter_cache: true
  belongs_to :plaque, counter_cache: true
  belongs_to :verb, counter_cache: true

  attr_accessor :other_verb_id

  validates_presence_of :verb_id, :person_id, :plaque_id

  def from
    year = started_at ? started_at.year.to_s : ""
    year = person.born_in.to_s if (verb.id == 8 || verb.id == 504)
    year = person.died_in.to_s if (verb.id == 3 || verb.id == 49 || verb.id == 161 || verb.id == 288 || verb.id == 292 || verb.id == 566 || verb.id == 779 || verb.id == 1103 || verb.id == 1108 || verb.id == 1147)
    year
  end

  def to
    year = ended_at ? ended_at.year.to_s : ""
    year = person.born_in.to_s if (verb.id == 8 || verb.id == 504)
    year = person.died_in.to_s if (verb.id == 3 || verb.id == 49 || verb.id == 161 || verb.id == 288 || verb.id == 292 || verb.id == 566 || verb.id == 779 || verb.id == 1103 || verb.id == 1108 || verb.id == 1147)
    year
  end

  def full_address
    plaque&.full_address
  end

  def single_year?
    from == to
  end

end
