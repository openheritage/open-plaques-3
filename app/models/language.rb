# A natural language, as defined by the ISO code.
# === Attributes
# * +alpha2+ - 2-letter code as defined by the ISO standard. Used in URLs.
# * +name+ - the language's common name
# * +plaques_count+ - cached count of plaques
class Language < ApplicationRecord
  has_many :plaques
  has_many :organisations

  validates_presence_of :name, :alpha2
  validates_uniqueness_of :alpha2
  validates_uniqueness_of :name
  scope :most_plaques_order, -> { order("plaques_count DESC nulls last") }

  def flag_icon
    fi = "flag-icon-#{alpha2}"
    fi = 'flag-icon-es-ct' if alpha2 == 'ca'
    fi = 'flag-icon-ie' if alpha2 == 'ga'
    fi = 'flag-icon-by' if alpha2 == 'be'
    fi = 'flag-icon-gb-wls' if alpha2 == 'wl'
    fi
  end

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
