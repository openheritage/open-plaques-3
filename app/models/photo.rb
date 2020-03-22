require 'wikimedia/commoner'

# A photograph of a plaque or a subject.
# === Attributes
# * +description+ - Extra information about what this is a photo of (used if not linked to a plaque)
# * +file_url+ - A link to the actual digital photo file.
# * +latitude+ - Optional
# * +longitude+ - Optional
# * +of_a_plaque+ - whether this is actually a photo of a plaque (and not, for example, mistakenly labelled on Wikimedia as one)
# * +photographer+ - The name of the photographer
# * +photographer_url+ - A link to a webpage for the photographer
# * +shot+ - Types of framing technique. One of "extreme close up", "close up", "medium close up", "medium shot", "long shot", "establishing shot"
# * +subject+ - What we think this is a photo of (used if not linked to a plaque)
# * +taken_at+ - Date and time if known
# * +thumbnail+ - A link to a thumbnail image if there is one
# * +url+ - The primary stable webpage for the photorequire 'wikimedia/commoner'
class Photo < ApplicationRecord
  belongs_to :plaque, counter_cache: true, optional: true
  belongs_to :person, optional: true
  belongs_to :licence, counter_cache: true, optional: true
  validates_presence_of :file_url
  validate :unique_file_url, on: :create
  after_update :reset_plaque_photo_count
  before_save :populate
  before_save :https_urls
  before_save :merge_known_photographer_names
  before_save :nearest_plaque
  before_save :set_of_a_plaque
  after_save :geolocate_plaque
  after_save :opposite_clone
  scope :reverse_detail_order, -> { order('shot DESC') }
  scope :detail_order, -> { order('shot ASC') }
  scope :unassigned, -> { where(plaque_id: nil, of_a_plaque: true) }
  scope :undecided, -> { where(plaque_id: nil, of_a_plaque: nil) }
  scope :wikimedia, -> { where("file_url like '%commons%'") }
  scope :flickr, -> { where("url like '%flickr.com%'") }
  scope :geograph, -> { where("photographer_url like 'https://www.geograph.org.uk/profile/%'") }
  scope :geolocated, -> { where(['latitude IS NOT NULL']) }
  scope :ungeolocated, -> { where(['latitude IS NULL']) }
  attr_accessor :photo_url, :accept_cc_by_licence

  def title
    title = 'a photo'
    title = "photo № #{id}" unless id.nil?
    title = "a photo of a #{plaque.title}" if plaque
    title = "a photo of #{person.name}" if person
    title
  end

  def attribution
    attrib = '&copy; '
    attrib += photographer.tr('./', '__') if photographer
    attrib += " on #{source}"
    attrib += " #{licence.abbreviation}" if licence && !licence.abbreviation.nil?
    attrib += " #{licence.name}" if licence && licence.abbreviation.nil?
    attrib
  end

  def shot_name
    return nil if shot == ''

    shot[4, shot.length] if shot
  end

  def shot_order
    return shot[0, 1] if shot && shot != ''

    6
  end

  def self.shots
    [
      '1 - extreme close up',
      '2 - close up',
      '3 - medium close up',
      '4 - medium shot',
      '5 - long shot',
      '6 - establishing shot'
    ]
  end

  def flickr?
    url&.include?('flickr.com')
  end

  def wikimedia?
    url&.include?('edia.org')
  end

  def geograph?
    url&.include?('geograph.org')
  end

  def source
    return 'Flickr' if flickr?

    return 'Wikimedia Commons' if wikimedia?

    return 'Geograph' if geograph?

    'the web'
  end

  def wikimedia_filename
    name = ''
    begin
      name = url[url.index('File:') + 5..-1] if wikimedia?
    rescue
      name = url.split('/').last
    end
    name
  end

  def wikimedia_special
    "https://commons.wikimedia.org/wiki/Special:FilePath/#{wikimedia_filename}?width=640"
  end

  # retrieve Flickr photo id from url e.g. http://www.flickr.com/photos/84195101@N00/3412825200/
  def self.flickr_photo_id(url)
    mtch = url.match(%r{flickr.com\/photos\/[^\/]*\/([^\/]*)})
    mtch ? mtch[1].to_s : nil
  end

  def thumbnail_url
    return thumbnail if thumbnail?

    if file_url.ends_with?(*%w[_b.jpg _z.jpg _z.jpg?zz=1 _m.jpg _o.jpg])
      return file_url.gsub('b.jpg', 'm.jpg').gsub('z.jpg?zz=1', 'm.jpg').gsub('z.jpg', 'm.jpg').gsub('o.jpg', 'm.jpg')

    end
    "https://commons.wikimedia.org/wiki/Special:FilePath/#{wikimedia_filename}?width=250" if wikimedia?
  end

  def populate
    wikimedia_data
    geograph_data
    flickr_data
  end

  def match
    return if plaque_id

    nearest_plaques&.each do |nearest|
      if nearest.inscription.downcase.include?(subject.downcase) || (
          subject.match(/([\w\s]*),/) &&
          nearest.inscription.downcase.include?(subject.match(/([\w\s]*),/)[1].downcase)
        )
        self.plaque_id = nearest.id
        break
      end
    end
  end

  def unlinked?
    plaque.nil? || person.nil?
  end

  def linked?
    !unlinked?
  end

  def ungeolocated?
    latitude.nil?
  end

  def geolocated?
    !ungeolocated?
  end

  def nearest_plaques
    return unless unlinked? && geolocated?

    distance = 0.01
    @plaques = Plaque.where(
      longitude: (longitude.to_f - distance)..(longitude.to_f + distance),
      latitude: (latitude.to_f - distance)..(latitude.to_f + distance)
    )
    @plaques.to_a.sort! { |a, b| a.distance_to(self) <=> b.distance_to(self) }
  end

  def nearest_plaque
    return unless unlinked? && geolocated?

    p = nearest_plaques.first
    if p
      self.nearest_plaque_id = p.id
      self.distance_to_nearest_plaque = p.distance_to(self)
    end
    p
  end

  def cloned?
    clone_id&.positive?
  end

  def preferred_clone?
    cloned? ? !flickr? : true
  end

  def as_json(options = {})
    if !options || !options[:only]
      options =
        {
          only: %i[file_url photographer photographer_url shot url longitude latitude],
          include: {
            licence: { only: [:name], methods: [:url] },
            plaque: { only: [], methods: [:uri] }
          },
          methods: %i[title uri thumbnail_url shot_name source]
        }
    end
    super options
  end

  def as_geojson(options = {})
    if !options || !options[:only]
      options =
        {
          only: %i[photographer photographer_url url],
          methods: %i[thumbnail_url shot_name source]
        }
    end
    {
      type: 'Feature',
      geometry:
      {
        type: 'Point',
        coordinates: [longitude, latitude]
      },
      properties: as_json(options)
    }
  end

  def uri
    'http://openplaques.org' + Rails.application.routes.url_helpers.photo_path(self, format: :json)
  end

  def to_s
    title
  end

  private

  def https_urls
    return unless flickr? || geograph? || wikimedia?

    self.url = url&.gsub('http:', 'https:')
    self.file_url = file_url&.gsub('http:', 'https:')
    self.thumbnail = thumbnail&.gsub('http:', 'https:')
    self.photographer_url = photographer_url&.gsub('http:', 'https:')
  end

  def unique_file_url
    errors.add(:file_url, 'already exists') if Photo.find_by_file_url(file_url) || Photo.find_by_file_url(file_url&.gsub('https', 'http'))
  end

  def reset_plaque_photo_count
    return unless saved_change_to_plaque_id?

    Plaque.reset_counters(plaque_id_before_last_save, :photos) unless plaque_id_before_last_save.nil? || plaque_id_before_last_save.zero?
    Plaque.reset_counters(plaque.id, :photos) unless plaque.nil? || plaque_id_before_last_save.zero?
  end

  def new?
    file_url.blank?
  end

  def wikimedia_data
    return unless wikimedia? && new?

    begin
      wikimedia = Wikimedia::Commoner.details("File:#{wikimedia_filename}")
      if wikimedia[:description] == 'missing'
        errors.add :file_url, "cannot find File:#{wikimedia_filename} on Wikimedia Commons"
      else
        self.url = wikimedia[:page_url]
        self.subject = wikimedia[:description].gsub('English: ', '')
        self.photographer = wikimedia[:author]
        self.photographer_url = wikimedia[:author_url]
        self.file_url = wikimedia_special

        if wikimedia[:licence_url]
          licence = Licence.find_by(url: wikimedia[:licence_url])
          unless licence
            wikimedia[:licence_url] += '/' unless wikimedia[:licence_url].ends_with? '/'
            licence = Licence.find_by_url wikimedia[:licence_url]
            unless licence
              if wikimedia[:licence]
                licence = Licence.new(
                  name: wikimedia[:licence],
                  url: wikimedia[:licence_url]
                )
                licence.save
              end
            end
          end
          self.licence = licence unless licence.nil?
        end
        self.latitude = wikimedia[:latitude] if wikimedia[:latitude]
        self.longitude = wikimedia[:longitude] if wikimedia[:longitude]
      end
    rescue RuntimeError => e
      errors.add :file_url, 'Commoner errored' + e.full_messages
    end
  end

  def geograph_data
    return unless geograph? && new?

    api = "http://api.geograph.org.uk/api/oembed?&&url=#{url}&output=json"
    response = URI.parse(api).open
    resp = response.read
    parsed_json = JSON.parse(resp)
    self.photographer = parsed_json['author_name']
    self.photographer_url = parsed_json['author_url'].gsub('http:', 'https:')
    self.thumbnail = parsed_json['thumbnail_url'].gsub('http:', 'https:')
    self.file_url = parsed_json['url'].gsub('http:', 'https:')
    self.licence = Licence.find_by_url(parsed_json['license_url'])
    self.subject = parsed_json['title'][0, 255] if parsed_json['title']
    self.description = parsed_json['description'] if parsed_json['description']
    self.latitude = parsed_json['geo']['lat'] if parsed_json['geo']
    self.longitude = parsed_json['geo']['long'] if parsed_json['geo']
  end

  def flickr_data
    return unless flickr? && new?

    flickr_photo_id = Photo.flickr_photo_id(url)
    return unless flickr_photo_id

    key = '86c115028094a06ed5cd19cfe72e8f8b'
    api = "https://api.flickr.com/services/rest/?api_key=#{key}&format=json&nojsoncallback=1&method=flickr.photos.getInfo&photo_id=#{flickr_photo_id}"
    puts "Flickr: #{api}"
    begin
      response = URI.parse(api).open
    rescue # random 502 bad gateway from Flickr
      sleep(5)
      response = URI.parse(api).open
    end
    resp = response.read
    parsed_json = JSON.parse(resp)
    if parsed_json['stat'] == 'fail'
      errors.add(:file_url, 'photo removed from Flickr')
      return
    end
    parsed_json = parsed_json['photo']
    self.url = parsed_json['urls']['url'][0]['_content']
    self.file_url = "https://farm#{parsed_json['farm']}.staticflickr.com/#{parsed_json['server']}/#{parsed_json['id']}_#{parsed_json['secret']}_z.jpg"
    self.photo_url = "https://www.flickr.com/photos/#{parsed_json['owner']['path_alias']}/#{parsed_json['id']}/"
    self.photographer = parsed_json['owner']['realname']
    self.photographer = parsed_json['owner']['username'] if photographer.empty?
    p_id = parsed_json['owner']['path_alias'] || parsed_json['owner']['nsid']
    self.photographer_url = "https://www.flickr.com/photos/#{p_id}/"
    self.licence = Licence.find_by_flickr_licence_id(parsed_json['license'])
    self.subject = parsed_json['title']['_content'].gsub('TxHM', '').gsub('Historical Marker', '').gsub('Marker', '')[0, 255]
    self.description = parsed_json['description']['_content']
    self.latitude = parsed_json['location']['latitude'] if parsed_json['location']
    self.longitude = parsed_json['location']['longitude'] if parsed_json['location']
    self.taken_at = parsed_json['dates']['taken'] if parsed_json['dates']
    if plaque_id.nil? && parsed_json['tags']
      parsed_json['tags']['tag'].each do |tag|
        machine_tag_id = tag['raw'].match(/openplaques:id=(\d*)/)
        self.plaque_id = machine_tag_id[1] if machine_tag_id
      end
    end
  end

  def geolocate_plaque
    if plaque && geolocated? && (!plaque.geolocated? || (plaque.geolocated? && !plaque.is_accurate_geolocation))
      plaque.longitude = longitude
      plaque.latitude = latitude
      plaque.is_accurate_geolocation = true
      plaque.save
    end
    true
  end

  def merge_known_photographer_names
    self.photographer = 'Nick Harrison' if photographer == 'nick.harrisonfli'
    self.photographer = 'Elliott Brown' if photographer == 'ell brown'
    self.photographer = 'Jez Nicholson' if photographer == "J'Roo"
    self.photographer = photographer.gsub(/\R+/, '')
  end

  def opposite_clone
    return unless clone_id&.positive?

    opposite = Photo.find(clone_id)
    return unless opposite.clone_id != id

    opposite.clone_id = id
    opposite.save
  end

  def set_of_a_plaque
    self.of_a_plaque = false if !person_id.nil? && person_id != 0
    self.of_a_plaque = true if !plaque_id.nil? && plaque_id != 0
  end
end
