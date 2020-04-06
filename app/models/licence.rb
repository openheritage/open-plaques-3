# A content licence, such as those produced by the Creative Commons organisation
# === Attributes
# * +abbreviation+ - short name, e.g. CC BY-NC-SA 2.0
# * +allows_commercial_reuse+ - commercial usage rights
# * +name+ - the full name
# * +photos_count+ - cached count of photos
# * +url+ - a permanent URL at which the licence.
class Licence < ApplicationRecord
  has_many :photos
  validates_presence_of :name, :url
  validates_uniqueness_of :url
  scope :by_popularity, -> { order('photos_count desc nulls last') }

  def self.find_by_flickr_licence_id(flickr_licence_id)
    case flickr_licence_id.to_s
    when '0'
      Licence.find_by_url('http://en.wikipedia.org/wiki/All_rights_reserved')
    when '1'
      Licence.find_by_url('http://creativecommons.org/licenses/by-nc-sa/2.0/')
    when '2'
      Licence.find_by_url('http://creativecommons.org/licenses/by-nc/2.0/')
    when '3'
      Licence.find_by_url('http://creativecommons.org/licenses/by-nc-nd/2.0/')
    when '4'
      Licence.find_by_url('http://creativecommons.org/licenses/by/2.0/')
    when '5'
      Licence.find_by_url('http://creativecommons.org/licenses/by-sa/2.0/')
    when '6'
      Licence.find_by_url('http://creativecommons.org/licenses/by-nd/2.0/')
    when '7'
      Licence.find_by_url('http://www.flickr.com/commons/usage/')
    when '8'
      Licence.find_by_url('http://www.usa.gov/copyright.shtml')
    when '9'
      Licence.find_by_url('http://creativecommons.org/publicdomain/zero/1.0/')
    when '10'
      Licence.find_by_url('http://creativecommons.org/publicdomain/mark/1.0/')
    else
      puts 'Could not find license'
      nil
    end
  end

  # technically, this returns the starting index but can be treated as boolean
  def creative_commons?
    url =~ %r{creativecommons.org\/licenses}i
  end

  def to_s
    name
  end

  def as_json(options = {})
    if !options || !options[:only]
      options = {
        only: %i[name abbreviation url allows_commercial_reuse photos_count]
      }
    end
    super options
  end
end
