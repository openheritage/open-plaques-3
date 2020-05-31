# frozen_string_literal: true

# The largest commonly identified region of residence below a country level.
# By this, we mean the place that people would normally name in answer to the
# question of 'where do you live?'.
# In most cases, this will be either a city (eg 'London'), town (eg 'Margate'),
# or village.
# It should not normally be either a state, county, district or other
# administrative region.
# === Attributes
# * +dbpedia_uri+ - uri to link to DBPedia record
# * +latitude+ - location
# * +longitude+ - location
# * +name+ - the area's common name (not neccessarily 'official')
# * +plaques_count+ - cached count of plaques
# * +slug+ - a textual identifier, usually equivalent to its name in lower case,
#            with spaces replaced by underscores. Used in URLs.
class Area < ApplicationRecord
  include ApplicationHelper
  include PlaquesHelper

  belongs_to :country, counter_cache: true
  has_many :plaques, dependent: :restrict_with_error
  delegate :alpha2, to: :country, prefix: true
  before_validation :make_slug_not_war
  validates_presence_of :name, :slug, :country_id
  validates_uniqueness_of :slug, scope: :country_id

  def name=(name)
    write_attribute(:name, name.try(:squish))
  end

  def geolocated?
    !(latitude.nil? || longitude.nil? || latitude == 51.475 && longitude.zero?)
  end

  def full_name
    "#{name}, #{country.name}"
  end

  def people
    people = []
    plaques.each do |plaque|
      next if plaque.people.nil?

      plaque.people.each do |person|
        people << person
      end
    end
    people.uniq
  end

  def as_json(options = nil)
    if !options || !options[:only]
      options = {
        only: %i[name plaques_count],
        include: {
          country: {
            only: [:name],
            methods: :uri
          }
        },
        methods: %i[uri plaques_uri]
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

  def uri
    return nil unless id && country

    path = Rails.application.routes.url_helpers.country_area_path(
      country, self, format: :json
    )
    "https://openplaques.org#{path}"
  end

  def plaques_uri
    return nil unless id && country

    path = Rails.application.routes.url_helpers.country_area_plaques_path(
      country, self, format: :json
    )
    "https://openplaques.org#{path}"
  end

  def main_photo
    random_plaque = plaques.photographed.random
    random_plaque ? random_plaque.main_photo : nil
  end

  def state
    matches = /(.*), ([A-Z][A-Z]\z)/.match(name)
    matches[2] if matches
  end

  def town
    matches = /(.*), ([A-Z][A-Z]\z)/.match(name)
    if matches
      matches[1]
    else
      name
    end
  end
end
