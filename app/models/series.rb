# A series of commemorative plaques
# This is often marked on the plaque itself
# === Attributes
# * +description+ - A description of when amd why a series was erected.
# * +latitude+
# * +longitude+
# * +name+ - The name of the series (as it appears on the plaques).
# * +plaques_count+
class Series < ApplicationRecord
  has_many :plaques

  attr_accessor :latitude, :longitude

  validates_presence_of :name
  default_scope { order('name ASC') }

  include PlaquesHelper

  def find_centre
    if !geolocated?
      @mean = find_mean(self.plaques)
      self.latitude = @mean.latitude
      self.longitude = @mean.longitude
    end
  end

  def geolocated?
    return !(self.latitude == nil && self.longitude == nil || self.latitude == 51.475 && self.longitude == 0)
  end

  def uri
    'http://openplaques.org' + Rails.application.routes.url_helpers.series_path(self.id, :format=>:json) if id
  end

  def as_json(options={})
    options =
    {
      only: [:name, :description, :plaques_count],
      methods: :uri
    } if !options[:only]
    super(options)
  end

  def main_photo
    random_photographed_plaque = plaques.photographed.order("random()").limit(1).first
    random_photographed_plaque ? random_photographed_plaque.main_photo : nil
  end

end
