# This class represents 'colours', as commonly identified as the main colour on commemorative
# plaques.
# === Attributes
# * +name+ - the colour's common name (eg 'blue').
# * +slug+ - An textual identifier for the colour, usually equivalent to its name in lower case, with spaces replaced by underscores. Used in URLs.
#
# === Associations
# * Plaques - plaques which use this colour.
class Colour < ActiveRecord::Base

  before_validation :make_slug_not_war
  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug

  has_many :plaques

  scope :common, where(:common => true)
  scope :uncommon, where(:common => false)

  include ApplicationHelper

  def to_param
    slug
  end
  
  def to_s
    name
  end

end
