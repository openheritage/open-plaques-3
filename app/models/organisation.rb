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
    in: %w(unknown unkown Unknown Unknown),
    message: "just leave it blank"
  }
  scope :name_starts_with, ->(term) { where(['lower(name) LIKE ?', term.downcase + '%']) }
  scope :name_contains, ->(term) { where(['lower(name) LIKE ?', '%' + term.downcase + '%']) }
  scope :name_is, ->(term) { where(['lower(name) = ?', term.downcase]) }
  scope :in_alphabetical_order, -> { order(name: :asc) }
  scope :in_count_order, -> { order(sponsorships_count: :desc) }

  # for slug helper
  include ApplicationHelper

  def plaques_count
    sponsorships_count
  end

  def geolocated?
    !(latitude.nil? && longitude.nil? || latitude == 51.475 && longitude.zero?)
  end

  def main_photo
    random_plaque = plaques.photographed.random.limit(1).first
    random_plaque&.main_photo
  end

  def uri
    "https://openplaques.org#{Rails.application.routes.url_helpers.organisation_path(self.slug, format: :json)}"
  end

  def plaques_uri
    "https://openplaques.org#{Rails.application.routes.url_helpers.organisation_plaques_path(self.slug, format: :geojson)}"
  end

  def as_json(options=nil)
    options = {
      only: [:name],
      methods: %i[uri plaques_count plaques_uri]
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
