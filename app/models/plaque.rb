require 'aws-sdk-translate'

# A physical commemorative plaque, which is either currently installed, or
# was once installed on a building, site or monument. Our definition of plaques is quite wide,
# encompassing 'traditional' blue plaques that commemorate a historic person's connection to a
# place, as well as plaques that commemorate buildings, events, and so on.
# === Attributes
# * +address+ - the physical street address
# * +description+ - additional information
# * +erected_at+ - The date on which the plaque was erected. Optional.
# * +inscription+ - The text inscription on the self.
# * +inscription_in_english+ - Manual translation
# * +inscription_is_stub+ - The inscription is incomplete and needs entering.
# * +is_accurate_geolocation+ -
# * +is_current+ - Whether the plaque is currently on display (or has it been stolen!)
# * +latitude+ - location (as a decimal in WSG-84 projection). Optional.
# * +longitude+ - location (as a decimal in WSG-84 projection). Optional.
# * +notes+ - A general purpose notes field for internal admin and data-collection purposes.
# * +parsed_inscription+ - (not used?)
# * +personal_connections_count+ -
# * +photos_count+ -
# * +reference+ - An official reference number or identifier for the self. Sometimes marked on the actual plaque itself, sometimes only in promotional material. Optional.
# * +series_ref+ - if part of a series does it have a reference number/id?
class Plaque < ApplicationRecord
  belongs_to :area, counter_cache: true, optional: true
  belongs_to :colour, counter_cache: true, optional: true
  belongs_to :language, counter_cache: true, optional: true
  belongs_to :series, counter_cache: true, optional: true
  has_many :personal_connections, dependent: :destroy
  has_many :photos, -> { where(of_a_plaque: true).order(:shot) }, inverse_of: :plaque
  has_many :sponsorships, dependent: :destroy
  has_many :organisations, through: :sponsorships
  has_one :pick
  delegate :name, to: :colour, prefix: true, allow_nil: true
  delegate :name, :alpha2, to: :language, prefix: true, allow_nil: true
  before_save :use_other_colour_id
  before_save :usa_townify
  before_save :unshout
  before_save :translate
  accepts_nested_attributes_for :photos, reject_if: proc { |attributes| attributes['photo_url'].blank? }
  scope :current, -> { where(is_current: true).order(id: :desc) }
  scope :geolocated, -> { where(['plaques.latitude IS NOT NULL']) }
  scope :ungeolocated, -> { where(latitude: nil).order(id: :desc) }
  scope :photographed, -> { where('photos_count > 0') }
  scope :unphotographed, -> { where(photos_count: 0, is_current: true).order(id: :desc) }
  scope :coloured, -> { where('colour_id IS NOT NULL') }
  scope :uncoloured, -> { where(colour_id: nil) }
  scope :photographed_not_coloured, -> { where(['photos_count > 0 AND colour_id IS NULL']) }
  scope :geo_no_location, -> { where(['latitude IS NOT NULL AND address IS NULL']) }
  scope :detailed_address_no_geo, -> { where(latitude: nil).where('address IS NOT NULL') } # TODO: fix this
  scope :unconnected, -> { where(personal_connections_count: 0).order(id: :desc) }
  scope :connected, -> { where('personal_connections_count > 0').order(id: :desc) }
  scope :no_description, -> { where("description = '' OR description IS NULL") }
  scope :partial_inscription, -> { where(inscription_is_stub: true).order(id: :desc) }
  scope :partial_inscription_photo, -> { where(photos_count: 1..99_999, inscription_is_stub: true).order(id: :desc) }
  scope :no_english_version, -> { where('language_id > 1').where(inscription_is_stub: false, inscription_in_english: nil) }
  scope :in_series_ref_order, -> { order(:series_ref) }
  attr_accessor :country, :other_colour_id, :force_us_state

  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  def coordinates
    geolocated? ? "#{latitude},#{longitude}" : ''
  end

  def full_address
    a = address || ''
    if area
      a += ", #{area&.name}"
      a += ", #{area.country&.name}"
    end
    a
  end

  def erected_at_string
    return unless erected_at?

    if erected_at.month == 1 && erected_at.day == 1
      erected_at.year.to_s
    else
      erected_at.to_s
    end
  end

  def erected_at_string=(date)
    if date.length == 4
      self.erected_at = Date.parse(date + '-01-01')
    else
      self.erected_at = date
    end
  end

  def geolocated?
    !latitude.nil? && !longitude.nil?
  end

  def roughly_geolocated?
    !geolocated? || (geolocated? && !is_accurate_geolocation)
  end

  def photographed?
    photos_count.positive?
  end

  def people
    if id
      sql = "select distinct people.*
        from personal_connections as pc_main
        inner join people on people.id = pc_main.person_id
        where pc_main.plaque_id = #{id}"
      @people ||= Person.find_by_sql(sql)
    else
      # not been saved yet
      people = []
      personal_connections.each do |pc|
        people << pc.person unless pc.person.nil? || pc.person.name.empty?
      end
      people.uniq
    end
  end

  def subjects
    number_of_subjects = 3
    if people.size == number_of_subjects + 1
      first_people = []
      people.first(number_of_subjects - 1).each do |person|
        first_people << person[:name]
      end
      first_people << pluralize(people.size - number_of_subjects + 1, 'other')
      first_people.to_sentence
    elsif people.size > number_of_subjects
      first_4_people = []
      people.first(number_of_subjects).each do |person|
        first_4_people << person[:name]
      end
      first_4_people << pluralize(people.size - number_of_subjects, 'other')
      first_4_people.to_sentence
    elsif !people.empty?
      people.collect(&:name).to_sentence
    end
  end

  def as_json(options = {})
    options = {
      only: %i[id inscription erected_at is_current updated_at latitude longitude],
      include: {
        photos: {
          only: [],
          methods: %i[uri thumbnail_url shot_name attribution]
        },
        organisations: {
          only: [:name],
          methods: [:uri]
        },
        language: {
          only: %i[name alpha2]
        },
        area: {
          only: :name,
          include: {
            country: {
              only: %i[name alpha2],
              methods: :uri
            }
          },
          methods: :uri
        },
        people: {
          only: [],
          methods: %i[uri full_name]
        },
        see_also: {
          only: [],
          methods: %i[uri]
        }
      },
      methods: %i[uri title address subjects colour_name machine_tag geolocated? photographed? thumbnail_url]
    } if !options || !options[:only]
    super options
  end

  def as_geojson(options = {})
    options = { only: %i[id uri inscription] } if !options || !options[:only]
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [longitude, latitude],
        is_accurate: is_accurate_geolocation
      },
      properties: as_json(options)
    }
  end

  def as_wkt
    geolocated? ? "POINT(#{longitude} #{latitude})" : ''
  end

  def machine_tag
    "openplaques:id=#{id}"
  end

  def wikimedia_tag
    "{{Open Plaques|plaqueid=#{id}}}"
  end

  def latitude
    super ? super.round(5) : nil
  end

  def longitude
    super ? super.round(5) : nil
  end

  def title
    if people.size > 4
      first_4_people = []
      people.first(4).each do |person|
        first_4_people << person[:name]
      end
      first_4_people << pluralize(people.size - 4, 'other')
      first_4_people.to_sentence
    elsif people.any?
      t = people.collect(&:name).to_sentence
      t += ' ' + colour_name if colour_name && colour_name != 'unknown'
      t + ' plaque'
    elsif colour_name && colour_name != 'unknown'
      "#{colour_name.to_s.capitalize} plaque № #{id}"
    elsif !id.nil?
      "plaque № #{id}"
    else
      'plaque'
    end
  end

  def main_photo
    @main_photo ||= photos.first&.preferred_clone? ? photos.first : photos.second
  end

  def other_photos
    others = []
    photos.each do |p|
      others << p if p != main_photo && p.preferred_clone?
    end
    others.uniq
  end

  def main_photo_reverse
    photos.reverse_detail_order.first unless photos.empty?
  end

  def thumbnail_url
    return nil if main_photo.nil?

    main_photo.thumbnail_url != '' ? main_photo.thumbnail_url : main_photo.file_url
  end

  def foreign?
    !(language.nil? || language&.alpha2 == 'en')
  end

  def see_also
    if id
      sql = "select distinct
        plaques.id,
        plaques.inscription,
        plaques.area_id,
        plaques.latitude,
        plaques.longitude
        from personal_connections as pc_main
        inner join personal_connections as pc_related
           on pc_related.person_id = pc_main.person_id
        inner join plaques on plaques.id = pc_related.plaque_id
        where pc_main.plaque_id = #{id}
          and pc_related.plaque_id != #{id}"
      @related_plaques ||= Plaque.find_by_sql(sql)
      ActiveRecord::Associations::Preloader.new.preload(@related_plaques, %i[photos area])
      @related_plaques
    else
      # not been saved yet
      []
    end
  end

  def inscription_preferably_in_english
    translate
    inscription_in_english && !inscription_in_english.blank? ? inscription_in_english : inscription
  end

  def erected?
    if erected_at?
      return false if erected_at.year > Date.today.year

      return false if erected_at.day != 1 && erected_at.month != 1 && erected_at > Date.today
    end

    true
  end

  def translate
    return unless foreign? && inscription_in_english.blank?

    begin
      client = Aws::Translate::Client.new(region: 'eu-west-1')
      resp = client.translate_text(
        {
          text: inscription,
          source_language_code: language.alpha2,
          target_language_code: 'en'
        }
      )
      self.inscription_in_english = "#{resp.translated_text} [AWS Translate]"
    rescue
      puts("plaque #{id} failed to translate")
    end
  end

  def self.tile(zoom, xtile, ytile, options)
    top_left = get_lat_lng_for_number(zoom, xtile, ytile)
    bottom_right = get_lat_lng_for_number(zoom, xtile + 1, ytile + 1)
    latitude = bottom_right[:lat_deg].to_s..top_left[:lat_deg].to_s
    longitude = top_left[:lng_deg].to_s..bottom_right[:lng_deg].to_s
    tile = '/plaques/'
    tile += options + '/' if options && options != '' && options != 'all'
    tile += "tiles/#{zoom}/#{xtile}/#{ytile}"
    if options == 'unphotographed'
      unphotographed
        .select(:id, :inscription, :latitude, :longitude, :is_accurate_geolocation)
        .where(latitude: latitude, longitude: longitude)
    elsif options == 'unconnected'
      unconnected
        .select(:id, :inscription, :latitude, :longitude, :is_accurate_geolocation)
        .where(latitude: latitude, longitude: longitude)
    else
      self
        .select(:id, :inscription, :latitude, :longitude, :is_accurate_geolocation)
        .where(latitude: latitude, longitude: longitude)
    end
  end

  def distance_to(thing)
    distance_between(latitude, longitude, thing.latitude, thing.longitude)
  end

  def distance_between(lat1, lon1, lat2, lon2)
    rad_per_deg = Math::PI / 180
    earth_radius_in_meters = 6_371_000
    lat1_rad = lat1.to_f * rad_per_deg
    lat2_rad = lat2.to_f * rad_per_deg
    lon1_rad = lon1.to_f * rad_per_deg
    lon2_rad = lon2.to_f * rad_per_deg
    a = Math.sin((lat2_rad - lat1_rad) / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    (earth_radius_in_meters * c).round # Delta in meters
  end

  def us_state
    return area.us_state if area

    return force_us_state if force_us_state

    matches = /(.*), ([A-Z][A-Z]\z)/.match(address)
    matches[2] if matches
  end

  def usa_townify
    return unless area.nil? && us_state

    usa = Country.find_by_alpha2('us')
    state_towns = Area.where("country_id = #{usa.id} and name like '%, #{us_state}'")
    state_towns.each do |town|
      # match any address that includes a town name from the state
      next unless town.name != ", #{us_state}" && address.include?(town.us_town)

      self.area = town
      self.address = address.reverse.sub(", #{town.name}".reverse, '').reverse.strip
      self.address = address.reverse.sub(town.name.reverse, '').reverse.strip
      self.address = address.reverse.sub("in #{town.us_town}".reverse, '').reverse.strip
      self.address = address.reverse.sub(", #{town.us_town}".reverse, '').reverse.strip
      break
    end
  end

  def uri
    'http://openplaques.org' + Rails.application.routes.url_helpers.plaque_path(self) if id
  end

  def to_s
    title
  end

  # from OpenStreetMap documentation
  def self.get_lat_lng_for_number(zoom, xtile, ytile)
    n = 2.0**zoom
    lon_deg = xtile / n * 360.0 - 180.0
    lat_rad = Math.atan(Math.sinh(Math::PI * (1 - 2 * ytile / n)))
    lat_deg = 180.0 * (lat_rad / Math::PI)
    { lat_deg: lat_deg, lng_deg: lon_deg }
  end

  # from OpenStreetMap documentation
  def self.get_tile_number(lat_deg, lng_deg, zoom)
    lat_rad = lat_deg / 180 * Math::PI
    n = 2.0**zoom
    x = ((lng_deg + 180.0) / 360.0 * n).to_i
    y = ((1.0 - Math.log(Math.tan(lat_rad) + (1 / Math.cos(lat_rad))) / Math::PI) / 2.0 * n).to_i
    { x: x, y: y }
  end

  private

  def use_other_colour_id
    self.colour_id = other_colour_id if !colour && other_colour_id
  end

  def unshout
    return unless inscription && inscription&.upcase == inscription

    # IT IS ALL IN CAPITALS, I AM SHOUTING
    self.inscription = inscription.capitalize
  end
end
