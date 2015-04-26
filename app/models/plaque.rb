# -*- encoding : utf-8 -*-
# This class represents a physical commemorative plaque, which is either currently installed, or
# was once installed on a building, site or monument. Our definition of plaques is quite wide,
# encompassing 'traditional' blue plaques that commemorate a historic person's connection to a
# place, as well as plaques that commemorate buildings, events, and so on.
#
# === Attributes
# * +inscription+ - The text inscription on the plaque.
# * +inscription_is_stub+ - The inscription is incomplete and needs entering.
# * +erected_at+ - The date on which the plaque was erected. Optional.
# * +reference+ - An official reference number or identifier for the plaque. Sometimes marked on the actual plaque itself, sometimes only in promotional material. Optional.
# * +latitude+ - The latitude of the plaque's location (as a decimal in WSG-84 projection). Optional.
# * +longitude+ - The longitude of the plaque's location (as a decimal in WSG-84 projection). Optional.
# * +notes+ - A general purpose notes field for internal admin and data-collection purposes.
# * +is_current+ - Whether the plaque is currently on display (or has it been stolen!)
# * +inscription_in_english+ - Manual translation
# * +address+ - the physical street address
#
# === Associations
# * Area - The area in which the plaque is (or was) installed. Optional.
# * Colour - The colour of the plaque. Optional.
# * Organisation - The organisation responsible for the plaque. Optional.
# * User - The user who first added the plaque to the website.
# * Language - The primary language of the inscripton on the plaque. Optional.
# * Photos - Photos of the plaque.
# * Verbs - The verbs used on the plaque's inscription.
# * Series - A series that this plaque is part of. Optional.
class Plaque < ActiveRecord::Base

  validates_presence_of :user

  belongs_to :colour, :counter_cache => true
  belongs_to :user, :counter_cache => true
  belongs_to :language, :counter_cache => true
  belongs_to :series, :counter_cache => true
  belongs_to :area, :counter_cache => true

  has_one :pick

  has_many :personal_connections
  has_many :photos, -> { where(of_a_plaque: true).order('shot ASC')}, :inverse_of => :plaque
  has_many :sponsorships
  has_many :organisations, :through => :sponsorships

  before_save :use_other_colour_id

  scope :current, -> { where(is_current: true).order('id desc') }
  scope :geolocated, ->  { where(["latitude IS NOT NULL"]) }
  scope :ungeolocated, -> { where(latitude: nil).order("id DESC") }
  scope :photographed, -> { where("photos_count > 0") }
  scope :unphotographed, -> { where(:photos_count => 0, :is_current => true).order("id DESC") }
  scope :coloured, -> { where("colour_id IS NOT NULL") }
  scope :photographed_not_coloured, -> { where(["photos_count > 0 AND colour_id IS NULL"]) }
  scope :geo_no_location, -> { where(["latitude IS NOT NULL AND address IS NULL"]) }
  scope :detailed_address_no_geo, -> { where(latitude: nil).where("address is not null") }  # TODO fix this
  scope :no_connection, -> { where(personal_connections_count: 0).order("id DESC") }
  scope :no_description, -> { where("description = '' OR description IS NULL") }
  scope :partial_inscription, -> { where(inscription_is_stub: true).order("id DESC") }
  scope :partial_inscription_photo, -> { where(photos_count: 1..99999, inscription_is_stub: true).order("id DESC") }
  scope :no_english_version, -> { where("language_id > 1").where(inscription_is_stub: false, inscription_in_english: nil) }
  
  attr_accessor :country, :other_colour_id

  delegate :name, :to => :colour, :prefix => true, :allow_nil => true
  delegate :name, :alpha2, :to => :language, :prefix => true, :allow_nil => true

  accepts_nested_attributes_for :photos, :reject_if => proc { |attributes| attributes['photo_url'].blank? }
  accepts_nested_attributes_for :user, :reject_if => :all_blank

  include ApplicationHelper, ActionView::Helpers::TextHelper

  def user_attributes=(user_attributes)
    if user_attributes.has_key?("email")
      user = User.find_by_email(user_attributes["email"])
      if user
        raise "Attempting To Post Plaque As Existing Verified User" and return if user.is_verified?
        self.user = user
      end
    end
    if !user
      build_user(user_attributes)
    end
  end

  def coordinates
    if geolocated?
      latitude.to_s + "," + longitude.to_s
    else
      ""
    end
  end

  def full_address
    a = address
    a += ", " + area.name + ", " + area.country.name if area
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
    !(latitude.nil?)
  end

  def photographed?
    photos_count > 0
  end

  def first_person
    if personal_connections.size > 0
      personal_connections[0].person.name
    else
      return nil
    end
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
    if options.size == 0
      options = 
    {
      :only => [:id, :inscription, :erected_at, :is_current, :updated_at],
      :include =>
      {
        :photos => 
        {
          :only => [], 
          :methods => [:uri, :thumbnail_url]
        },
        :organisations =>
        {
          :only => [:name],
          :methods => [:uri]
        },
        :language =>
        {
          :only => [:name, :alpha2]
        },
        :area => 
        {
          :only => :name, 
          :include => 
          {
            :country => 
            {
              :only => [:name, :alpha2],
              :methods => :uri
            }
          },
          :methods => :uri
        },
        :people => 
        {
          :only => [], 
          :methods => [:uri, :full_name]
        },
        :see_also => 
        {
          :only => [],
          :methods => [:uri]
        }
      },
      :methods => [:uri, :title, :address, :subjects, :colour_name, :machine_tag, :geolocated?, :photographed?, :photo_url, :thumbnail_url, :shot_name]
    }
    end

    # use a geojson format wrapper
    {
      type: 'Feature',
      geometry: 
      {
        type: 'Point',
        coordinates: [self.longitude, self.latitude],
        is_accurate: self.is_accurate_geolocation
      },
      properties: 
        super(options)
    }
  end

  def machine_tag
    "openplaques:id=" + id.to_s
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
      else
        "plaque № #{id}"
      end # << " in " + area.name if area
    rescue Exception => e
      "plaque № #{id}"
    end
  end

  def main_photo
    @main_photo ||= photos.first
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
    return inscription_in_english if inscription_in_english && inscription_in_english > ""
    return inscription
  end
  
  def erected?
    return false if erected_at? && erected_at.year > Date.today.year
    return false if erected_at? &&erected_at.day!=1 && erected_at.month!=1 && erected_at > Date.today
    true
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
    Rails.cache.fetch(tile, :expires_in => 5.minutes) do
      if options == "unphotographed"
        Plaque.unphotographed.where(:latitude => latitude, :longitude => longitude)
      else
        Plaque.where(:latitude => latitude, :longitude => longitude)
      end
    end
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.plaque_path(self, :format => :json) if id
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
      {:lat_deg => lat_deg, :lng_deg => lon_deg}
    end

    # from OpenStreetMap documentation
    def Plaque.get_tile_number(lat_deg, lng_deg, zoom)
      lat_rad = lat_deg/180 * Math::PI
      n = 2.0 ** zoom
      x = ((lng_deg + 180.0) / 360.0 * n).to_i
      y = ((1.0 - Math::log(Math::tan(lat_rad) + (1 / Math::cos(lat_rad))) / Math::PI) / 2.0 * n).to_i
      {:x => x, :y =>y}
    end

end
