# This class represents 'colours', as commonly identified as the main colour on commemorative
# plaques.
# === Attributes
# * +name+ - the colour's common name (eg 'blue').
# * +slug+ - An textual identifier for the colour, usually equivalent to its name in lower case, with spaces replaced by underscores. Used in URLs.
# * +common+ - whether this is a commonly used colour
# * +plaques_count+ - cached count of plaques
#
# === Associations
# * Plaques - plaques which use this colour.
class Colour < ActiveRecord::Base

  before_validation :make_slug_not_war
  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug

  has_many :plaques

  scope :common, -> { where(common: true) }
  scope :uncommon, ->  { where(common: false) }
  scope :most_plaques_order, -> { order("plaques_count DESC") }

  include ApplicationHelper # for help with making slugs

  def to_param
    slug
  end

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.colour_path(self, :format => :json)
  end
  
  def to_s
    name
  end

  def as_json(options={})
    options = {
      :only => [:name, :plaques_count, :common],
      :include => { },
      :methods => [:uri]
    } if !options[:prefixes].blank?
    super(options)
  end

end
