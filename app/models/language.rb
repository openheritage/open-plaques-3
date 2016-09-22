# This class represents natural languages, as defined by the ISO code.
# === Attributes
# * +name+ - the language's common name
# * +alpha2+ - 2-letter code as defined by the ISO standard. Used in URLs.
# * +plaques_count+ - cached count of plaques
#
# === Associations
# * Plaques - plaques which are mainly written in this language.
class Language < ActiveRecord::Base

  validates_presence_of :name, :alpha2
  validates_uniqueness_of :alpha2
  validates_uniqueness_of :name # Unlikely there will be two languages with the same name.

  has_many :plaques

  scope :most_plaques_order, -> { order("plaques_count DESC nulls last") }

  def to_param
    alpha2
  end

  def to_s
    name
  end

  def as_json(options={})
    options = {
      only: [:name, :alpha2, :plaques_count],
      include: { },
      methods: []
    } if !options[:prefixes].blank?
    super(options)
  end

end
