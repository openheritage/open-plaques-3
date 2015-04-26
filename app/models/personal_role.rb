# This class represents a connection between a Person and a Role.
# === Attributes
# * +started_at+ - when the person started doing what they did at the place
# * +ended_at+ - when the person stopped doing what they did at the place
# * +ordinal+ - whether they were the first, second, third, or not stated
# === Associations
# * Person - the person to whom this connection applies
# * Role - the role referenced in this connection.
# * Related Person - optional related person for special roles like 'wife' or 'mother'
class PersonalRole < ActiveRecord::Base

  validates_presence_of :person_id, :role_id

  belongs_to :person, :counter_cache => true
  belongs_to :role, :counter_cache => true
  belongs_to :related_person, :class_name => "Person"
  
  def date_range
    dates = ""
    dates += "from " + started_at.to_s.sub('-01-01','') if started_at
    dates += " " if started_at && ended_at
    dates += "to " + ended_at.to_s.sub('-01-01','') if ended_at
    return dates
  end

end
