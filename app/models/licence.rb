# This class represents content licences, such as those produced by the Creative Commons
# organisation.
# === Attributes
# * +name+ - the licence's full name
# * +url+ - a permanent URL at which the licence.
#
# === Associations
# * Plaques - plaques which are mainly written in this language.
class Licence < ActiveRecord::Base

  validates_presence_of :name, :url
  validates_uniqueness_of :url

  has_many :photos
  
  def self.find_by_flickr_licence_id(flickr_licence_id)
    case flickr_licence_id
    when "4"
      return Licence.find_by_url("http://creativecommons.org/licenses/by/2.0/")
    when "6"
      return Licence.find_by_url("http://creativecommons.org/licenses/by-nd/2.0/")
    when "3"
      return Licence.find_by_url("http://creativecommons.org/licenses/by-nc-nd/2.0/")
    when "2"
      return Licence.find_by_url("http://creativecommons.org/licenses/by-nc/2.0/")
    when "1"
      return Licence.find_by_url("http://creativecommons.org/licenses/by-nc-sa/2.0/")
    when "5"
      return Licence.find_by_url("http://creativecommons.org/licenses/by-sa/2.0/")
    when "7"
      return Licence.find_by_url("http://www.flickr.com/commons/usage/")
    when "0"
      return Licence.find_by_url("http://en.wikipedia.org/wiki/All_rights_reserved/")
    else
      puts "Couldn't find license"
      return nil
    end
  end

end
