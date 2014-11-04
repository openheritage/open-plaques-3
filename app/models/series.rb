# This class represents a series of commemorative plaques often to commemorate an event such as a town's anniversary. 
# A Series is usually marked on the plaque itself
#
# === Attributes
# * +name+ - The name of the series (as it appears on the plaques).
# * +description+ - A description of when amd why a series was erected.
#
# === Associations
# * Plaques - plaques in this series.
class Series < ActiveRecord::Base

  validates_presence_of :name

  has_many :plaques

end
