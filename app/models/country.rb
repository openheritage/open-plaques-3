# A top-level region definition as defined by the ISO country codes specification.
# === Attributes
# * +alpha2+ - 2-letter ISO standard code. Used in URLs.
# * +areas_count+ - cached count of areas
# * +description+ - commentary on how this region commemorates subjects
# * +latitude+ - location
# * +longitude+ - location
# * +name+ - the country's common name (not necessarily its official one).
# * +wikidata_id+ - Q-code to match to Wikidata
class Country < ApplicationRecord
  include PlaquesHelper

  has_many :areas
  has_many :plaques, through: :areas
  validates_presence_of :name, :alpha2
  validates_uniqueness_of :name, :alpha2
  after_commit :notify_slack, on: :create
  scope :uk, -> { where(alpha2: 'gb').first }

  def geolocated?
    !(latitude.nil? || longitude.nil? || latitude == 51.475 && longitude.zero?)
  end

  def plaques_count
    @plaques_count ||= areas.sum(:plaques_count)
  end

  def zoom
    preferred_zoom_level || 6
  end

  def as_json(options = {})
    if !options || !options[:only]
      options = {
        only: [:name],
        methods: %i[uri plaques_count areas_count]
      }
    end
    super options
  end

  def to_param
    alpha2
  end

  def uri
    "http://openplaques.org#{Rails.application.routes.url_helpers.country_path(self, format: :json)}" if id
  end

  def to_s
    name || ''
  end

  def notify_slack
    hook = ENV.fetch('SLACKHOOK', '')
    return if hook.empty?

    notifier = Slack::Notifier.new(hook)
    notifier.ping "Country <a href='#{uri}'>#{name}</a> was just created. ISO code #{alpha2}"
  end
end
