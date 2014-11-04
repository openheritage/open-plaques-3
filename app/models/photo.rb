# -*- encoding : utf-8 -*-
# This class represents a photograph of a Plaque.
#
# === Attributes
# * +url+ - The primary stable webpage for the photo
# * +file_url+ - A link to the actual digital photo file.
# * +thumbnail+ - A link to a thumbnail image if there is one
# * +photographer+ - The name of the photographer
# * +photographer_url+ - A link to a webpage for the photographer
# * +shot+ - types of framing technique. One of "extreme close up", "close up", "medium close up", "medium shot", "long shot", "establishing shot"
# * +of_a_plaque+ - whether this is actually a photo of a plaque (and not, for example, mistakenly labelled on Wikimedia as one)
# * +subject+ - what we think this is a photo of (used if not linked to a plaque)
# * +description+ - extra information about what this is a photo of (used if not linked to a plaque)
# * +longitude+
# * +latitude+
#
# === Associations
# * Licence - The content licence under which the photo is made available.
# * Plaque - the featured in the photo.
require 'curb'
require 'nokogiri'
require 'sanitize'

class Photo < ActiveRecord::Base

  belongs_to :plaque, :counter_cache => true
  belongs_to :licence, :counter_cache => true
  belongs_to :user
  belongs_to :person

  validates_presence_of :file_url
  validates_uniqueness_of :file_url, :message => "photo already exists in Open Plaques"
  
  attr_accessor :photo_url, :accept_cc_by_licence

  after_initialize :assign_from_photo_url
  before_validation :assign_licence_if_cc_by_accepted
  after_update :reset_plaque_photo_count
  after_save :geolocate_plaque

  scope :reverse_detail_order, -> { order('shot DESC') }
  scope :detail_order, -> { order('shot ASC') }
  scope :unassigned, :conditions => ["plaque_id IS NULL AND of_a_plaque = 't'"]
  scope :undecided, :conditions => ["plaque_id IS NULL AND of_a_plaque IS NULL"]

  def assign_from_photo_url
    if @photo_url
      if @photo_url =~ /http\:\/\/www\.flickr\.com\/photos\/.+\/\d+\//
        self.url = @photo_url
      else
        self.file_url = @photo_url
      end
    end
  end

  def assign_licence_if_cc_by_accepted
    if @accept_cc_by_licence && @licence_id.blank?
      self.licence = Licence.find_or_create_by_name_and_url("Attribution License", "http://creativecommons.org/licenses/by/3.0/")
      self.photographer = self.plaque.user.name
    end
  end

  def title
    if self.plaque
      return "a photo of a " + self.plaque.to_s
    end
    if self.person
      return "a photo of " + self.person.to_s
    end
    title = "photo № #{id}"
    if plaque
      title = ""
      if shot_name
        title += shot_name
      else
        title += "photo"
      end
      title += " of " + plaque.title.indefinitize
    end
    return title
  end
  
  def shot_name
    return nil if shot == ''
    return shot[3,shot.length] if shot
  end
  
  def shot_order
    return shot[0,1] if shot && shot != ''
    6
  end

  def self.shots
    ["1 - extreme close up", "2 - close up", "3 - medium close up", "4 - medium shot", "5 - long shot", "6 - establishing shot"]
  end
  
  def ping?
    begin # check header response
      case Net::HTTP.get_response(URI.parse(file_url))
        when Net::HTTPSuccess then return true
        else return false
      end
    rescue # Recover optimistically on DNS failures..
	  return true
    end 
  end
  
  def flickr?
    url && url.starts_with?("http://www.flickr.com")
  end
  
  def wikimedia?
    url.gsub!("http://en.wikipedia.org/","http://commons.wikimedia.org/")
    url.gsub!("https","http")
    url && url.starts_with?("http://commons.wikimedia.org")
  end
  
  def geograph?
    url && url.starts_with?("http://www.geograph.org.uk")
  end
  
  def source
    return "Flickr" if flickr?
    return "Wikimedia Commons" if wikimedia?
    return "Geograph" if geograph?
    return "the web"
  end
  
  def wikimedia_filename
    return url[url.index('File:')+5..-1] if wikimedia?
    return ""
  end
  
  def wikimedia_special
    return "http://commons.wikimedia.org/wiki/Special:FilePath/"+wikimedia_filename+"?width=640"
  end
  
  def flickr_photo_id
    # retrieve from url e.g. http://www.flickr.com/photos/84195101@N00/3412825200/
  end

  def thumbnail_url
    return self.thumbnail if self.thumbnail?
    if (file_url.ends_with?("_b.jpg") or file_url.ends_with?("_z.jpg") or file_url.ends_with?("_z.jpg?zz=1") or file_url.ends_with?("_m.jpg") or file_url.ends_with?("_o.jpg"))
      return file_url.gsub("b.jpg", "s.jpg").gsub("z.jpg?zz=1", "s.jpg").gsub("z.jpg", "s.jpg").gsub("m.jpg", "s.jpg").gsub("o.jpg", "s.jpg")
    end
    if (wikimedia?)
      return "http://commons.wikimedia.org/wiki/Special:FilePath/"+wikimedia_filename+"?width=75"
    end
  end
  
  # http://commons.wikimedia.org/w/api.php?action=query&iiprop=url|user&prop=imageinfo&format=json&titles=File:George_Dance_plaque.JPG
  def wikimedia_data
    # http://commons.wikimedia.org/wiki/File:George_Dance_plaque.JPG
    # http://commons.wikimedia.org/wiki/File:Abney1.jpg
    if (wikimedia?)
#      query_url = "http://commons.wikimedia.org/w/api.php?action=query&iiprop=url|user&prop=imageinfo&format=json&titles=File:"+wikimedia_filename
#      begin
#        ch = Curl::Easy.perform(query_url) do |curl| 
#          curl.headers["User-Agent"] = "openplaques"
#          curl.verbose = true
#        end
#        parsed_json = JSON.parse(ch.body_str)
#        parsed_json['query']['pages'].each do |page, pageInfo|
#          self.photographer = pageInfo['imageinfo'][0]['user']
#        end
#        self.photographer_url = "http://commons.wikimedia.org/wiki/User:"+photographer.gsub(' ','_')
#      rescue
#      end
      doc = Nokogiri::HTML(open("http://commons.wikimedia.org/wiki/File:"+wikimedia_filename))
      doc.xpath('//td[@class="description"]').each do |v|
        self.subject = Sanitize.clean(v.content)[0,255]
      end
      doc.xpath('//tr[td/@id="fileinfotpl_aut"]/td').each do |v|
        self.photographer = Sanitize.clean(v.content)
      end
      doc.xpath('//tr[td/@id="fileinfotpl_aut"]/td/a/@href').each do |v|
        value = v.content
        self.photographer_url = value
        self.photographer_url = "http://commons.wikimedia.org" + value if value.start_with?('/')
      end
      self.file_url = wikimedia_special
      self.licence = Licence.find_or_create_by_name_and_url("Attribution License", "http://creativecommons.org/licenses/by/3.0/")
    end
    if (geograph?)   
      query_url = "http://api.geograph.org.uk/api/oembed?&&url=" + self.url + "&output=json"
      begin
        ch = Curl::Easy.perform(query_url) do |curl| 
          curl.headers["User-Agent"] = "openplaques"
          curl.verbose = true
        end
        parsed_json = JSON.parse(ch.body_str)
        puts parsed_json
        self.photographer = parsed_json['author_name']
        self.photographer_url = parsed_json['author_url']
        self.thumbnail = parsed_json['thumbnail_url']
        self.file_url = parsed_json['url']
        self.licence = Licence.find_by_url(parsed_json['license_url'])
        self.subject = parsed_json['title'][0,255]
        self.description = parsed_json['description'][0,255]
        self.latitude = parsed_json['geo']['lat']
        self.longitude = parsed_json['geo']['long']
      rescue
      end
    end
  end
  
  def linked?
    !(plaque.nil?)
  end
  
  def as_json(options={})
    # this example ignores the user's options
    super(:only => [:file_url, :photographer, :photographer_url, :shot, :url],
      :include => {
        :licence => {:only => [:name], :methods => [:uri]},
        :plaque => {:only => [], :methods => [:uri]}
      },
      :methods => [:title, :uri, :thumbnail, :shot_name, :source]
    )
  end
  
  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.photo_path(self, :format => :json)
  end
  
  def to_s
    self.title
  end
  
  private
  
    def reset_plaque_photo_count
      if plaque_id_changed?
        Plaque.reset_counters(plaque_id_was, :photos) unless plaque_id_was == nil
        Plaque.reset_counters(plaque.id, :photos) unless plaque == nil
      end
    end
    
    def geolocate_plaque
      if plaque && self.longitude && self.latitude && !plaque.geolocated?
        plaque.longitude = self.longitude
        plaque.latitude = self.latitude
        plaque.save
      end  
      return true      
    end
end
