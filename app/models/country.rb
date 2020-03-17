# A top-level region definition as defined by the ISO country codes specification.
# === Attributes
# * +alpha2+ - 2-letter ISO standard code. Used in URLs.
# * +areas_count+ - cached count of areas
# * +description+ - commentary on how this region commemorates subjects
# * +latitude+ - location
# * +longitude+ - location
# * +name+ - the country's common name (not necessarily its official one).
# * +plaques_count+ - cached count of plaques
# * +wikidata_id+ - Q-code to match to Wikidata
class Country < ApplicationRecord
  has_many :areas
  has_many :plaques, through: :areas

  validates_presence_of :name, :alpha2
  validates_uniqueness_of :name, :alpha2

  @@p_count = 0

  include PlaquesHelper

  def geolocated?
    !(latitude.nil? || longitude.nil? || latitude == 51.475 && longitude.zero?)
  end

  def plaques_count
    @@p_count = areas.sum(:plaques_count) if @@p_count = 0
    @@p_count
  end

  def zoom
    self.preferred_zoom_level || 6
  end

  def as_json(options = {})
    options = {
      only: [:name],
      methods: [:uri, :plaques_count, :areas_count]
    } if !options || !options[:only]
    super options
  end

  def to_param
    alpha2
  end

  def uri
    "http://openplaques.org#{Rails.application.routes.url_helpers.country_path(self, format: :json)}" if id
  end

  def to_s
    name
  end

end
