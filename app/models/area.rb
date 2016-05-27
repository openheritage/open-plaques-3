# This class represents 'areas', which are the largest commonly identified region of
# residence  below a country level. By this, we mean the place that people would normally
# name in answer to the question of 'where do you live?' In most cases, this will be either
# a city (eg 'London'), town (eg 'Margate'), or village. It should not normally be either a
# state, county, district or other administrative region.
#
# === Attributes
# * +name+ - the area's common name (not neccessarily 'official')
# * +slug+ - an identifier used in URLs. Normally a lower-cased version of name, with spaces replaced by underscores
# * +latitude+ - Mean location of plaques
# * +longitude+ - Mean location of plaques
# * +plaques_count+ - cached count of plaques
#
# === Associations
# * Country - country in which the area falls geographically or administratively.
# * Locations - places that are in this are
# * Plaques - plaques located in this area (via locations).

class Area < ActiveRecord::Base

  before_validation :make_slug_not_war, :find_centre
  validates_presence_of :name, :slug, :country_id
  validates_uniqueness_of :slug, :scope => :country_id

  belongs_to :country, :counter_cache => true
  delegate :alpha2, :to => :country, :prefix => true
  has_many :plaques

  default_scope { order('name ASC') }
  scope :name_starts_with, lambda {|term| where(["lower(name) LIKE ?", term.downcase + "%"]) }
  scope :name_contains, lambda {|term| where(["lower(name) LIKE ?", "%" + term.downcase + "%"]) }

  include ApplicationHelper
  include PlaquesHelper

  def find_centre
    if !geolocated?
      @mean = find_mean(self.plaques.geolocated)
      self.latitude = @mean.latitude
      self.longitude = @mean.longitude
    end
  end

  def geolocated?
    return !(self.latitude == nil || self.longitude == nil || self.latitude == 51.475 && self.longitude == 0)
  end

  def full_name
    name + ", " + country.name
  end

  def people
    people = Array.new
    plaques.each do |plaque|
      if plaque.people != nil
        plaque.people.each do |person|
          people << person
        end 
      end
    end
    return people.uniq
  end
  
  def as_json(options=nil)
    options = {
      :only => [:name, :plaques_count],
      :include => { 
        :country => {
          :only => [:name],
          :methods => :uri
        }
      },
      :methods => [:uri, :plaques_uri]
    } if !options || !options[:only]
    super options
  end

  def as_geojson(options=nil)
    {
      type: 'Feature',
      geometry:
      {
        type: 'Point',
        coordinates: [self.longitude, self.latitude]
      },
      properties: as_json(options)
    }
  end

  def as_wkt()
    return "" if (self.longitude == nil || self.latitude == nil)
    "POINT(" + self.longitude + " " + self.latitude + ")"
  end
  
  def to_param
    slug
  end
  
  def to_s
    name
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.country_area_path(self.country, self, :format => :json) if id && country
  end

  def plaques_uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.country_area_plaques_path(self.country, self, :format => :json) if id && country
  end

end
