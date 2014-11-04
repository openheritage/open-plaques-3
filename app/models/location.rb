# This class represents a physical location at which a plaques is located. This is commonly a
# single property, building, monument or other landmark. Not that Locations do NOT map directly
# to a geographical co-ordinate - instead it is better to think of them as 'addresses' or very
# small areas.
# === Attributes
# * +name+ - The name of the location - often the same as the first line of its address (eg '56 High Street'). Other examples might be 'Speakers Corner, Hyde Park' or 'Manchester War Memorial'.
#
# === Associations
# * Area - area in which the location is physically located.
# * Country - country in which the location is physically located.
# * People - people with a connection to this location
# * Plaques - plaques installed at this location
# * Verbs - verbs used to describe connections to this location
class Location < ActiveRecord::Base

  validates_presence_of :name

  belongs_to :area, :counter_cache => true
  belongs_to :country, :counter_cache => true

  has_many :personal_connections
  has_many :people, :through => :personal_connections
  has_many :plaques
  has_many :verbs, :through => :personal_connections #, :uniq => true

  scope :no_area, :conditions => ["area_id IS NULL"]

  before_validation :update_country_id
  
  def full_address
    address = name
    address += ", " + area.name if area
	  address += ", " + area.country.name if area and area.country
  end

  private

  def update_country_id
    if self.area && self.area.country_id
      self.country_id = self.area.country_id
    end
  end

end
