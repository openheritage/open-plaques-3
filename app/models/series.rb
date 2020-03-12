# A series of commemorative plaques
# This is normally marked on the plaque itself
# === Attributes
# * +description+ - A description of when and why the series was erected
# * +latitude+
# * +longitude+
# * +name+ - The name of the series as it appears on the plaques
# * +plaques_count+
class Series < ApplicationRecord
  has_many :plaques

  validates_presence_of :name
  scope :in_alphabetical_order, -> { order('name ASC') }
  scope :in_count_order, -> { order('plaques_count DESC') }

  def main_photo
    random_plaque = plaques.photographed.random.limit(1).first
    random_plaque&.main_photo
  end

  def geolocated?
    return !(latitude.nil? && longitude.nil? || latitude == 51.475 && longitude.zero?)
  end

  def zoom
    10
  end

  def uri
    'http://openplaques.org' + Rails.application.routes.url_helpers.series_path(id, format: :json) if id
  end

  def as_json(options={})
    options =
    {
      only: %i(:name, :description, :plaques_count),
      methods: :uri
    } unless options[:only]
    super(options)
  end
end
