# -*- encoding : utf-8 -*-
# A photograph of a plaque or a subject.
#
# === Attributes
# * +photographer+ - The name of the photographer
# * +url+ - The primary stable webpage for the photo
# * +created_at+
# * +updated_at+
# * +file_url+ - A link to the actual digital photo file.
# * +photographer_url+ - A link to a webpage for the photographer
# * +taken_at+ - Date and time if known
# * +shot+ - Types of framing technique. One of "extreme close up", "close up", "medium close up", "medium shot", "long shot", "establishing shot"
# * +of_a_plaque+ - whether this is actually a photo of a plaque (and not, for example, mistakenly labelled on Wikimedia as one)
# * +latitude+ - Optional
# * +longitude+ - Optional
# * +subject+ - What we think this is a photo of (used if not linked to a plaque)
# * +description+ - Extra information about what this is a photo of (used if not linked to a plaque)
# * +thumbnail+ - A link to a thumbnail image if there is one
require 'wikimedia/commoner'

class Photo < ApplicationRecord

  belongs_to :plaque, counter_cache: true, optional: true
  belongs_to :person, optional: true
  belongs_to :licence, counter_cache: true, optional: true

  attr_accessor :photo_url, :accept_cc_by_licence

  validates_presence_of :file_url
  validate :unique_file_url, on: :create
  after_update :reset_plaque_photo_count
  before_save :geograph_data
  before_save :https_flickr_urls
  before_save :merge_known_photographer_names
  before_save :nearest_plaque
  after_save :geolocate_plaque
  after_save :opposite_clone
  scope :reverse_detail_order, -> { order('shot DESC') }
  scope :detail_order, -> { order('shot ASC') }
  scope :unassigned, -> { where(plaque_id: nil, of_a_plaque: true) }
  scope :undecided, -> { where(plaque_id: nil, of_a_plaque: nil) }
  scope :wikimedia, -> { where("file_url like '%commons%'") }
  scope :flickr, -> { where("url like '%flickr.com%'") }
  scope :geograph, -> { where("url like '%geograph.org%'") }
  scope :geolocated, -> { where(["latitude IS NOT NULL"]) }
  scope :ungeolocated, -> { where(["latitude IS NULL"]) }

  def title
    title = "a photo"
    title = "photo № #{id}" if id != nil
    title = "a photo of a #{plaque.title}" if plaque
    title = "a photo of #{person.name}" if person
    title
  end

  def attribution
    attrib = '&copy; '
    attrib += photographer.tr("./","__") if photographer
    attrib += " on #{source}"
    attrib += " #{licence.abbreviation}" if licence && licence.abbreviation != nil
    attrib += " #{licence.name}" if licence && licence.abbreviation == nil
    attrib
  end

  def shot_name
    return nil if shot == ''
    return shot[4,shot.length] if shot
  end

  def shot_order
    return shot[0,1] if shot && shot != ''
    6
  end

  def self.shots
    ["1 - extreme close up", "2 - close up", "3 - medium close up", "4 - medium shot", "5 - long shot", "6 - establishing shot"]
  end

  def flickr?
    url && url.include?("flickr.com")
  end

  def wikimedia?
    url && url.include?("edia.org")
  end

  def geograph?
    url && url.include?("geograph.org")
  end

  def source
    return "Flickr" if flickr?
    return "Wikimedia Commons" if wikimedia?
    return "Geograph" if geograph?
    return "the web"
  end

  def wikimedia_filename
    name = ''
    begin
      name = url[url.index('File:')+5..-1] if wikimedia?
    rescue
      name = url.split('/').last
    end
    name
  end

  def wikimedia_special
    return "https://commons.wikimedia.org/wiki/Special:FilePath/"+wikimedia_filename+"?width=640"
  end

  # retrieve Flickr photo id from url e.g. http://www.flickr.com/photos/84195101@N00/3412825200/
  def self.flickr_photo_id(url)
    mtch = url.match(/flickr.com\/photos\/[^\/]*\/([^\/]*)/)
    mtch ? "#{mtch[1]}" : nil
  end

  def thumbnail_url
    return self.thumbnail if self.thumbnail?
    if (file_url.ends_with?("_b.jpg") or file_url.ends_with?("_z.jpg") or file_url.ends_with?("_z.jpg?zz=1") or file_url.ends_with?("_m.jpg") or file_url.ends_with?("_o.jpg"))
      return file_url.gsub("b.jpg", "m.jpg").gsub("z.jpg?zz=1", "m.jpg").gsub("z.jpg", "m.jpg").gsub("m.jpg", "m.jpg").gsub("o.jpg", "m.jpg")
    end
    return "https://commons.wikimedia.org/wiki/Special:FilePath/#{wikimedia_filename}?width=250" if wikimedia?
  end

  def wikimedia_data
    if wikimedia?
      begin
        wikimedia = Wikimedia::Commoner.details("File:#{wikimedia_filename}")
        if wikimedia[:description] == 'missing'
          errors.add :file_url, "cannot find File:#{wikimedia_filename} on Wikimedia Commons"
        else
          self.url = wikimedia[:page_url]
          self.subject = wikimedia[:description]
          self.photographer = wikimedia[:author]
          self.photographer_url = wikimedia[:author_url]
          self.file_url = wikimedia_special
          licence = Licence.find_by(url: wikimedia[:licence_url])
          if (licence == nil)
            wikimedia[:licence_url] += "/" if !wikimedia[:licence_url].ends_with? '/'
            licence = Licence.find_by_url wikimedia[:licence_url]
            if (licence == nil)
              licence = Licence.new(name: wikimedia[:licence], url: wikimedia[:licence_url])
              licence.save
            end
          end
          self.licence = licence if licence != nil
          self.latitude = wikimedia[:latitude] if wikimedia[:latitude]
          self.longitude = wikimedia[:longitude] if wikimedia[:longitude]
        end
      rescue
        errors.add :file_url, 'Commoner errored'
      end
    end
    if geograph?
      query_url = "http://api.geograph.org.uk/api/oembed?&&url=#{self.url}&output=json"
      response = open(query_url)
      resp = response.read
      parsed_json = JSON.parse(resp)
      self.photographer = parsed_json['author_name']
      self.photographer_url = parsed_json['author_url'].gsub("http:","https:")
      self.thumbnail = parsed_json['thumbnail_url'].gsub("http:","https:")
      self.file_url = parsed_json['url'].gsub("http:","https:")
      self.licence = Licence.find_by_url(parsed_json['license_url'])
      self.subject = parsed_json['title'][0,255] if parsed_json['title']
      self.description = parsed_json['description'][0,255] if parsed_json['description']
      self.latitude = parsed_json['geo']['lat'] if parsed_json['geo']
      self.longitude = parsed_json['geo']['long'] if parsed_json['geo']
    end
    if flickr?
      flickr_photo_id = Photo.flickr_photo_id(url)
      if flickr_photo_id
        key = "86c115028094a06ed5cd19cfe72e8f8b"
        q_url = "https://api.flickr.com/services/rest/?api_key=#{key}&format=json&nojsoncallback=1&method=flickr.photos.getInfo&photo_id=#{flickr_photo_id}"
        puts "Flickr: #{q_url}"
        response = open(q_url)
        resp = response.read
        parsed_json = JSON.parse(resp)
        if parsed_json['stat'] == 'fail'
          errors.add(:file_url, "photo removed from Flickr")
          return
        end
        parsed_json = parsed_json['photo']
        self.url = parsed_json['urls']['url'][0]['_content']
        self.file_url = "https://farm#{parsed_json['farm']}.staticflickr.com/#{parsed_json['server']}/#{parsed_json['id']}_#{parsed_json['secret']}_z.jpg"
        self.photo_url = "https://www.flickr.com/photos/#{parsed_json['owner']['path_alias']}/#{parsed_json['id']}/"
        self.photographer = parsed_json['owner']['realname']
        self.photographer = parsed_json['owner']['username'] if self.photographer.empty?
        p_id = parsed_json['owner']['path_alias'] ? parsed_json['owner']['path_alias'] : parsed_json['owner']['nsid']
        self.photographer_url = "https://www.flickr.com/photos/#{p_id}/"
        self.licence = Licence.find_by_flickr_licence_id(parsed_json['license'])
        self.subject = parsed_json['title']['_content'][0,255]
        self.description = parsed_json['description']['_content']
        self.latitude = parsed_json['location']['latitude'] if parsed_json['location']
        self.longitude = parsed_json['location']['longitude'] if parsed_json['location']
        self.taken_at = parsed_json['dates']['taken'] if parsed_json['dates']
        if self.plaque_id == nil && parsed_json['tags']
          parsed_json['tags']['tag'].each do |tag|
            machine_tag_id = tag['raw'].match(/openplaques:id=(\d*)/)
            self.plaque_id = machine_tag_id[1] if machine_tag_id
          end
        end
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
    if (unlinked? && geolocated?)
      distance = 0.01
      @plaques = Plaque.where(
        longitude: (longitude.to_f - distance)..(longitude.to_f + distance),
        latitude: (latitude.to_f - distance)..(latitude.to_f + distance)
      )
      @plaques.to_a.sort! { |a,b| a.distance_to(self) <=> b.distance_to(self) }
    end
  end

  def nearest_plaque
    if (unlinked? && geolocated?)
      p = nearest_plaques.first
      if (p)
        self.nearest_plaque_id = p.id
        self.distance_to_nearest_plaque = p.distance_to(self)
      end
      p
    end
  end

  def as_json(options={})
    options =
    {
      only: [:file_url, :photographer, :photographer_url, :shot, :url, :longitude, :latitude],
      include: {
        licence: {only: [:name], methods: [:url]},
        plaque: {only: [], methods: [:uri]}
      },
      methods: [:title, :uri, :thumbnail_url, :shot_name, :source]
    } if !options || !options[:only]
    super options
  end

  def as_geojson(options={})
    options =
    {
      only: [:photographer, :photographer_url, :url],
      methods: [:thumbnail_url, :shot_name, :source]
    } if !options || !options[:only]
    {
      type: 'Feature',
      geometry:
      {
        type: 'Point',
        coordinates: [self.longitude, self.latitude]
      },
      properties: as_json(options)
    }
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.photo_path(self, format: :json)
  end

  def to_s
    self.title
  end

  private

    def https_flickr_urls
      if flickr?
        self.url = self.url.gsub("http:","https:")
        self.file_url = self.file_url.gsub("http:","https:")
        self.photographer_url = self.photographer_url.gsub("http:","https:")
      end
    end

    def unique_file_url
      errors.add(:file_url, "already exists") if Photo.find_by_file_url(file_url) || Photo.find_by_file_url(file_url.gsub("https","http"))
    end

    def reset_plaque_photo_count
      if plaque_id_changed?
        Plaque.reset_counters(plaque_id_was, :photos) unless plaque_id_was == nil || plaque_id_was == 0
        Plaque.reset_counters(plaque.id, :photos) unless plaque == nil || plaque_id_was == 0
      end
    end

    def geograph_data
      if geograph? && !geolocated?
        wikimedia_data
      end
    end

    def geolocate_plaque
      if plaque && self.geolocated? && (!plaque.geolocated? || (plaque.geolocated? && !plaque.is_accurate_geolocation))
        plaque.longitude = self.longitude
        plaque.latitude = self.latitude
        plaque.is_accurate_geolocation = true
        plaque.save
      end
      return true
    end

    def merge_known_photographer_names
      self.photographer = "Nick Harrison" if self.photographer == "nick.harrisonfli"
      self.photographer = "Elliott Brown" if self.photographer == "ell brown"
      self.photographer = "Jez Nicholson" if self.photographer == "J'Roo"
    end

    def opposite_clone
      if self.clone_id && self.clone_id > 0
        opposite = Photo.find(self.clone_id)
        if opposite.clone_id != self.id
          opposite.clone_id = self.id
          opposite.save
        end
      end
    end
end
