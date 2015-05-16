# This class represents 'countries', as defined by the ISO country codes specification.
# === Attributes
# * +name+ - the country's common name (not necessarily its official one).
# * +alpha2+ - 2-letter code as defined by the ISO standard. Used in URLs.
# * +dbpedia_uri+ - uri to link to DBPedia record
# * +areas_count+ - cached count of areas
# * +plaques_count+ - cached count of plaques (does not work)
#
# === Associations
# * Areas - areas located in this country.
#
# === Indirect Associations
# * Plaques - plaques which are located in this country.

class Country < ActiveRecord::Base

  validates_presence_of :name, :alpha2
  validates_uniqueness_of :name, :alpha2

  has_many :areas
  has_many :plaques, :through => :areas

  @@latitude = nil
  @@longitude = nil

  include PlaquesHelper

  def find_centre
    if !geolocated?
      @mean = find_mean(self.areas)
      @@latitude = @mean.latitude
      @@longitude = @mean.longitude
    end
  end

  def geolocated?
    return !(@@latitude == nil || @@longitude == nil || @@latitude == 51.475 && @@longitude == 0)
  end

  def latitude
    @@latitude
  end

  def longitude
    @@longitude
  end

  def zoom
    6
  end

  # Construct paths using the alpha2 code
  def to_param
    alpha2
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.country_path(self, :format => :json) if id
  end

  def to_s
    name
  end

  def as_json(options={})
    find_centre
    if options[:size] == 0
      options = {
        :only => [:name, :uri, :dbpedia_uri],
        :include => { :areas => {:only => [:name], :methods => :uri}},
        :methods => [:uri]
      }
    end
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [@@longitude, @@latitude]
      },
      properties:
        super(options)
    }
  end

end
