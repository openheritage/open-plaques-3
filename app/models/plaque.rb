# -*- encoding : utf-8 -*-
# A physical commemorative plaque, which is either currently installed, or
# was once installed on a building, site or monument. Our definition of plaques is quite wide,
# encompassing 'traditional' blue plaques that commemorate a historic person's connection to a
# place, as well as plaques that commemorate buildings, events, and so on.
#
# === Attributes
# * +erected_at+ - The date on which the plaque was erected. Optional.
# * +latitude+ - location (as a decimal in WSG-84 projection). Optional.
# * +longitude+ - location (as a decimal in WSG-84 projection). Optional.
# * +created_at+
# * +updated_at+
# * +inscription+ - The text inscription on the plaque.
# * +reference+ - An official reference number or identifier for the plaque. Sometimes marked on the actual plaque itself, sometimes only in promotional material. Optional.
# * +notes+ - A general purpose notes field for internal admin and data-collection purposes.
# * +parsed_inscription+ - (not used?)
# * +photos_count+ -
# * +description+ -
# * +inscription_is_stub+ - The inscription is incomplete and needs entering.
# * +personal_connections_count+ -
# * +is_accurate_geolocation+ -
# * +is_current+ - Whether the plaque is currently on display (or has it been stolen!)
# * +inscription_in_english+ - Manual translation
# * +series_ref+ - if part of a series does it have a reference number/id?
# * +address+ - the physical street address
class Plaque < ActiveRecord::Base

  belongs_to :area, counter_cache: true
  belongs_to :colour, counter_cache: true
  belongs_to :language, counter_cache: true
  belongs_to :series, counter_cache: true
  has_many :personal_connections
  has_many :photos, -> { where(of_a_plaque: true).order('shot ASC')}, inverse_of: :plaque
  has_many :sponsorships
  has_many :organisations, through: :sponsorships
  has_one :pick

  attr_accessor :country, :other_colour_id
  delegate :name, to: :colour, prefix: true, allow_nil: true
  delegate :name, :alpha2, to: :language, prefix: true, allow_nil: true

  before_save :use_other_colour_id
  accepts_nested_attributes_for :photos, reject_if: proc { |attributes| attributes['photo_url'].blank? }
  scope :current, -> { where(is_current: true).order('id desc') }
  scope :geolocated, ->  { where(["plaques.latitude IS NOT NULL"]) }
  scope :ungeolocated, -> { where(latitude: nil).order('id DESC') }
  scope :photographed, -> { where("photos_count > 0") }
  scope :unphotographed, -> { where(photos_count: 0, is_current: true).order("id DESC") }
  scope :coloured, -> { where("colour_id IS NOT NULL") }
  scope :uncoloured, -> { where(colour_id: nil) }
  scope :photographed_not_coloured, -> { where(["photos_count > 0 AND colour_id IS NULL"]) }
  scope :geo_no_location, -> { where(["latitude IS NOT NULL AND address IS NULL"]) }
  scope :detailed_address_no_geo, -> { where(latitude: nil).where("address is not null") }  # TODO fix this
  scope :unconnected, -> { where(personal_connections_count: 0).order("id DESC") }
  scope :connected, -> { where("personal_connections_count > 0").order("id DESC") }
  scope :no_description, -> { where("description = '' OR description IS NULL") }
  scope :partial_inscription, -> { where(inscription_is_stub: true).order("id DESC") }
  scope :partial_inscription_photo, -> { where(photos_count: 1..99999, inscription_is_stub: true).order("id DESC") }
  scope :no_english_version, -> { where("language_id > 1").where(inscription_is_stub: false, inscription_in_english: nil) }

  include ApplicationHelper, ActionView::Helpers::TextHelper

  def coordinates
    geolocated? ? latitude.to_s + "," + longitude.to_s : ""
  end

  def full_address
    a = address
    a += ", " + area.name + ", " + area.country.name if area
    a
  end

  def erected_at_string
    if erected_at?
      if erected_at.month == 1 && erected_at.day == 1
        erected_at.year.to_s
      else
        erected_at.to_s
      end
    else
      nil
    end
  end

  def erected_at_string=(date)
    if date.length == 4
      self.erected_at = Date.parse(date + "-01-01")
    else
      self.erected_at = date
    end
  end

  def geolocated?
    !(latitude.nil?) && !(longitude.nil?)
  end

  def roughly_geolocated?
    !self.geolocated? || (self.geolocated? && !self.is_accurate_geolocation)
  end

  def photographed?
    photos_count > 0
  end

  def people
    people = Array.new
    personal_connections.each do |personal_connection|
      if personal_connection.person != nil && personal_connection.person.name != ""
        people << personal_connection.person
      end
    end
    return people.uniq
  end

  def subjects
    number_of_subjects = 3
    if people.size == number_of_subjects + 1
      first_people = []
      people.first(number_of_subjects - 1).each do |person|
        first_people << person[:name]
      end
      first_people << pluralize(people.size - number_of_subjects + 1, "other")
      first_people.to_sentence
    elsif people.size > number_of_subjects
      first_4_people = []
      people.first(number_of_subjects).each do |person|
        first_4_people << person[:name]
      end
      first_4_people << pluralize(people.size - number_of_subjects, "other")
      first_4_people.to_sentence
    elsif people.size > 0
      people.collect(&:name).to_sentence
    end
  end

  def as_json(options={})
    options =
    {
      only: [:id, :inscription, :erected_at, :is_current, :updated_at, :latitude, :longitude],
      include:
      {
        photos:
        {
          only: [],
          methods: [:uri, :thumbnail_url, :shot_name, :attribution]
        },
        organisations:
        {
          only: [:name],
          methods: [:uri]
        },
        language:
        {
          only: [:name, :alpha2]
        },
        area:
        {
          only: :name,
          include:
          {
            country:
            {
              only: [:name, :alpha2],
              methods: :uri
            }
          },
          methods: :uri
        },
        people:
        {
          only: [],
          methods: [:uri, :full_name]
        },
        see_also:
        {
          only: [],
          methods: [:uri]
        }
      },
      methods: [:uri, :title, :address, :subjects, :colour_name, :machine_tag, :geolocated?, :photographed?, :photo_url, :thumbnail_url]
    } if !options || !options[:only]
    super options
  end

  def as_geojson(options={})
    options =
    {
      only: [:id, :uri, :inscription]
    } if !options || !options[:only]
    {
      type: 'Feature',
      geometry:
      {
        type: 'Point',
        coordinates: [self.longitude, self.latitude],
        is_accurate: self.is_accurate_geolocation
      },
      properties: as_json(options)
    }
  end

  def as_wkt()
    return "" if (self.longitude == nil || self.latitude == nil)
    "POINT(" + self.longitude + " " + self.latitude + ")"
  end

  def machine_tag
    "openplaques:id=" + id.to_s
  end

  def wikimedia_tag
    "{{Open Plaques|plaqueid=" + id.to_s + "}}"
  end

  def latitude
    super ? super.round(5) : nil
  end

  def longitude
    super ? super.round(5) : nil
  end

  def title
    begin
      if people.size > 4
        first_4_people = []
        people.first(4).each do |person|
          first_4_people << person[:name]
        end
        first_4_people << pluralize(people.size - 4, "other")
        first_4_people.to_sentence
      elsif people.size > 0
        t = people.collect(&:name).to_sentence
        t += " " + colour_name if colour_name && "unknown"!=colour_name
        t + " plaque"
      elsif colour_name && "unknown"!=colour_name
        colour_name.to_s.capitalize + " plaque № #{id}"
      elsif id != nil
        "plaque № #{id}"
      else
        "plaque"
      end # << " in " + area.name if area
    rescue Exception => e
      "plaque № #{id}"
    end
  end

  def main_photo
    @main_photo ||= photos.first
  end

  def other_photos
    others = []
    photos.each do |p|
      others << p unless p == main_photo
    end
    others
  end

  def main_photo_reverse
    if !photos.empty?
      return photos.reverse_detail_order.first
    end
  end

  def thumbnail_url
    return nil if main_photo == nil
    main_photo.thumbnail_url != "" ? main_photo.thumbnail_url : main_photo.file_url
  end

  def foreign?
    begin
      language.alpha2 != "en"
    rescue
      false
    end
  end

  def see_also
    also = []
    people.each do |person|
      person.plaques.each do |plaque|
        also << plaque unless plaque == self
      end
    end
	  return also.inject([]){|s,e| s | [e] }
  end

  def inscription_preferably_in_english
    translate
    inscription_in_english && !inscription_in_english.blank? ? inscription_in_english : inscription
  end

  def erected?
    return false if erected_at? && erected_at.year > Date.today.year
    return false if erected_at? && erected_at.day!=1 && erected_at.month!=1 && erected_at > Date.today
    true
  end

  def translate
    if foreign? && inscription_in_english.blank? && language.alpha2 == "de"
      in_english = inscription
      in_english = in_english.gsub('Hier wohnte','Here lived')
      in_english = in_english.gsub('jg.','born')
      in_english = in_english.gsub('deportiert','deported')
      in_english = in_english.gsub('Deportiert','deported')
      in_english = in_english.gsub('ermordet','murdered')
      in_english = in_english.gsub('Ermordet','murdered')
      in_english = in_english.gsub('geb.','nee')
      in_english = in_english.gsub('geb.','nee')
      in_english = in_english.gsub('geb.','nee')
      in_english = in_english.gsub('geb.','nee')
      in_english = in_english.gsub('flucht','escaped')
      in_english = in_english.gsub('interniert','interned')
      self.inscription_in_english = in_english
    end
  end

  def Plaque.tile(zoom, xtile, ytile, options)
    top_left = get_lat_lng_for_number(zoom, xtile, ytile)
    bottom_right = get_lat_lng_for_number(zoom, xtile + 1, ytile + 1)
    lat_min = bottom_right[:lat_deg].to_s
    lat_max = top_left[:lat_deg].to_s
    lon_min = bottom_right[:lng_deg].to_s
    lon_max = top_left[:lng_deg].to_s
    latitude = lat_min..lat_max
    longitude = lon_max..lon_min
    tile = "/plaques/"
    tile+= options + "/" if options != 'all'
    tile+= "tiles" + "/" + zoom.to_s + "/" + xtile.to_s + "/" + ytile.to_s
    puts "Rails query " + tile
#    Rails.cache.fetch(tile, expires_in: 5.minutes) do
      if options == "unphotographed"
        Plaque.unphotographed.select(:id, :inscription, :latitude, :longitude, :is_accurate_geolocation).where(latitude: latitude, longitude: longitude)
      else
        Plaque.select(:id, :inscription, :latitude, :longitude, :is_accurate_geolocation).where(latitude: latitude, longitude: longitude)
      end
#    end
  end

  def distance_to(thing)
    distance_between(self.latitude, self.longitude, thing.latitude, thing.longitude)
  end

  def distance_between(lat1, lon1, lat2, lon2)
    rad_per_deg = Math::PI / 180
    rm = 6371000 # Earth radius in meters
    lat1_rad, lat2_rad = lat1.to_f * rad_per_deg, lat2.to_f * rad_per_deg
    lon1_rad, lon2_rad = lon1.to_f * rad_per_deg, lon2.to_f * rad_per_deg
    a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))
    (rm * c).round # Delta in meters
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.plaque_path(self) if id
  end

  def to_s
    title
  end

  private

    def use_other_colour_id
      if !colour && other_colour_id
        self.colour_id = other_colour_id
      end
    end

    # from OpenStreetMap documentation
    def Plaque.get_lat_lng_for_number(zoom, xtile, ytile)
      n = 2.0 ** zoom
      lon_deg = xtile / n * 360.0 - 180.0
      lat_rad = Math::atan(Math::sinh(Math::PI * (1 - 2 * ytile / n)))
      lat_deg = 180.0 * (lat_rad / Math::PI)
      {lat_deg: lat_deg, lng_deg: lon_deg}
    end

    # from OpenStreetMap documentation
    def Plaque.get_tile_number(lat_deg, lng_deg, zoom)
      lat_rad = lat_deg/180 * Math::PI
      n = 2.0 ** zoom
      x = ((lng_deg + 180.0) / 360.0 * n).to_i
      y = ((1.0 - Math::log(Math::tan(lat_rad) + (1 / Math::cos(lat_rad))) / Math::PI) / 2.0 * n).to_i
      {x: x, y: y}
    end

end
