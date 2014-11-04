# This class represents a calendar year in which plaques were erected.
#
# === Attributes
# * +name+ - The name (number) of the year, eg '2000'.
# * +plaques_count+ - The number of plaques erected in this year.
#
# === Associations
# * Plaques - The plaques erected in this year.
class PlaqueErectedYear < ActiveRecord::Base

  validates_presence_of :name

  validates_uniqueness_of :name

  has_many :plaques

  def as_json(options={})
    super(options.merge(:only => [:name, :plaques_count]))
  end

end
