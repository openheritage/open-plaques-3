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

  belongs_to :person, counter_cache: true
  belongs_to :role, counter_cache: true
  belongs_to :related_person, class_name: "Person"

  def date_range
    dates = ""
    dates += "from " + started_at.to_s.sub('-01-01','') if started_at
    dates += " " if started_at && ended_at
    dates += "to " + ended_at.to_s.sub('-01-01','') if ended_at
    return dates
  end

  def year_range
    dates = ""
    start_year = started_at.to_s[0..3]
    dates += start_year if started_at
    end_year = ended_at.to_s[0..3]
    end_year = "" if end_year == start_year
    end_year = end_year[2..3] if end_year[0..1] == start_year[0..1]
    dates += "-" + end_year if end_year != ""
    return dates
  end

  def name
    n = role.name
    if related_person
      n += ' of ' + related_person.name
    end
    n
  end
end
