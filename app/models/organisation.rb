# An organisation involved in erecting commemorative plaques.
# Famous examples include English Heritage, civic societies or local councils.
# === Attributes
# * +description+ - a textual description
# * +latitude+ - mean location of plaques
# * +longitude+ - mean location of plaques
# * +name+ - The official name of the organisation
# * +notes+ - textual set of notes
# * +slug+ - an identifier for the organisation, usually equivalent to its name
# *          in lower case, with spaces replaced by underscores. Used in URLs.
# * +sponsorships_count+ - equivalent of number of plaques
# * +website+ - official web site
class Organisation < ApplicationRecord
  has_many :sponsorships, dependent: :restrict_with_error
  has_many :plaques, through: :sponsorships
  belongs_to :language, optional: true
  before_validation :make_slug_not_war
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  validates :name, exclusion: {
    in: %w[unknown unkown Unknown Unknown],
    message: 'just leave it blank'
  }
  scope :by_popularity, -> { order(sponsorships_count: :desc) }

  # for slug helper
  include ApplicationHelper

  def plaques_count
    sponsorships_count
  end

  def geolocated?
    !(latitude.nil? && longitude.nil? || latitude == 51.475 && longitude.zero?)
  end

  def main_photo
    random_plaque = plaques.photographed.random
    random_plaque&.main_photo
  end

  def uri
    "https://openplaques.org#{Rails.application.routes.url_helpers.organisation_path(slug, format: :json)}"
  end

  def plaques_uri
    "https://openplaques.org#{Rails.application.routes.url_helpers.organisation_plaques_path(slug, format: :geojson)}"
  end

  def as_json(options = nil)
    if !options || !options[:only]
      options = {
        only: [:name],
        methods: %i[uri plaques_count plaques_uri]
      }
    end
    super options
  end

  def to_param
    slug
  end

  def to_s
    name
  end
end
