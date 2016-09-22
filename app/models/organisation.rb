# An organisation involved in erecting commemorative plaques.
# Famous examples include 'English Heritage' - other examples may be civic societies or local councils.
# === Attributes
# * +name+ - The official name of the organisation
# * +website+ - official web site
# * +slug+ - An identifier for the organisation, usually equivalent to its name in lower case, with spaces replaced by underscores. Used in URLs.
# * +description+ - A textual description
# * +notes+ - A textual set of notes
# * +latitude+ - Mean location of plaques
# * +longitude+ - Mean location of plaques
# * +sponsorships_count+ - The equivalent of number of plaques
class Organisation < ActiveRecord::Base

  has_many :sponsorships
  has_many :plaques, through: :sponsorships

  before_validation :make_slug_not_war, :find_centre
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  scope :name_starts_with, lambda {|term| where(["lower(name) LIKE ?", term.downcase + "%"]) }
  scope :name_contains, lambda {|term| where(["lower(name) LIKE ?", "%" + term.downcase + "%"]) }

  include ApplicationHelper
  include PlaquesHelper

  def zoom
    10
  end

  def most_prevelant_colour
    @plaques = self.plaques
    most_prevelant_colour = @plaques.map {|i| (i.colour.nil? || i.colour.name) || "" }.group_by {|col| col }.max_by(&:size)
    @colour = most_prevelant_colour ? most_prevelant_colour.first : ""
  end

  def find_centre
    if !geolocated?
      @mean = find_mean(self.plaques)
      self.latitude = @mean.latitude
      self.longitude = @mean.longitude
    end
  end

  def plaques_count
    sponsorships_count
  end

  def geolocated?
    return !(self.latitude == nil && self.longitude == nil || self.latitude == 51.475 && self.longitude == 0)
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.organisation_path(self.slug, :format=>:json) if id
  end

  def plaques_uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.organisation_plaques_path(self.slug, format: :geojson) if id
  end

  def as_json(options=nil)
    options = {
      only: [:name],
      methods: [:uri, :plaques_count, :plaques_uri]
    } if !options || !options[:only]
    super options
  end

  def to_param
    slug
  end

  def to_s
    name
  end

end
