# A commemoration of a subject on a plaque. This acts as a 'join' between the two.
# === Attributes
# * +ended_at+ - when the subject stopped doing what they did at the place
# * +started_at+ - when the subject started doing what they did at the place
# * +plaque_connections_count+ - Cached count of plaques
class PersonalConnection < ApplicationRecord
  belongs_to :person, counter_cache: true
  belongs_to :plaque, counter_cache: true
  belongs_to :verb, counter_cache: true
  validates_presence_of :verb_id, :person_id, :plaque_id
  attr_accessor :other_verb_id

  # this would be a Verb query, but data is fixed and this is used frequently
  def birth?
    [8, 504].include?(verb.id)
  end

  # this would be a Verb query, but data is fixed and this is used frequently
  def death?
    [3, 49, 161, 288, 292, 566, 779, 1103, 1108, 1147].include?(verb.id)
  end

  def from
    year = started_at ? started_at.year.to_s : ''
    year = person.born_in.to_s if birth?
    year = person.died_in.to_s if death?
    year
  end

  def to
    year = ended_at ? ended_at.year.to_s : ''
    year = person.born_in.to_s if birth?
    year = person.died_in.to_s if death?
    year
  end

  def full_address
    plaque&.full_address
  end

  def single_year?
    from == to
  end
end
