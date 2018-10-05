# An organisation involved in erecting commemorative plaques.
# Famous examples include 'English Heritage' - other examples may be civic societies or local councils.
# === Attributes
# * +name+ - The official name of the organisation
# * +website+ - official web site
# * +created_at+
# * +updated_at+
# * +notes+ - textual set of notes
# * +slug+ - an identifier for the organisation, usually equivalent to its name in lower case, with spaces replaced by underscores. Used in URLs.
# * +description+ - a textual description
# * +sponsorships_count+ - equivalent of number of plaques
# * +latitude+ - mean location of plaques
# * +longitude+ - mean location of plaques
class Organisation < ApplicationRecord

  has_many :sponsorships
  has_many :plaques, through: :sponsorships
  belongs_to :language, optional: true

  before_validation :make_slug_not_war, :find_centre
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  validates :name, exclusion: { in: %w(unknown unkown Unknown Unknown), message: "just leave it blank" }
  scope :name_starts_with, lambda { |term| where(["lower(name) LIKE ?", term.downcase + "%"]) }
  scope :name_contains, lambda { |term| where(["lower(name) LIKE ?", "%" + term.downcase + "%"]) }
  scope :in_alphabetical_order, -> { order('name ASC') }

  include ApplicationHelper
  include PlaquesHelper

  def zoom
    10
  end

  def most_prevelant_colour
    @plaques = self.plaques
    most_prevelant_colour = @plaques.map { |i| (i.colour.nil? || i.colour.name) || "" }.group_by {|col| col }.max_by(&:size)
    @colour = most_prevelant_colour ? most_prevelant_colour.first : ""
  end

  def find_centre
    unless geolocated?
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
    "http://openplaques.org#{Rails.application.routes.url_helpers.organisation_path(self.slug, :format=>:json)}"
  end

  def plaques_uri
    "http://openplaques.org#{Rails.application.routes.url_helpers.organisation_plaques_path(self.slug, format: :geojson)}"
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

  def main_photo
    random_photographed_plaque = plaques.photographed.order("random()").limit(1).first
    random_photographed_plaque ? random_photographed_plaque.main_photo : nil
  end
end
