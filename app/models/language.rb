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
  scope :most_plaques_order, -> { order('plaques_count DESC nulls last') }

  def flag_icon
    alpha = alpha2[0, 2]
    case alpha
    when 'cs' # Czech
      alpha = 'cz'
    when 'be' # Belarusian
      alpha = 'by'
    when 'ca' # Catalan
      alpha = 'es-ct'
    when 'la' # Latin
      alpha = 'it'
    when 'cy' # Welsh
      alpha = 'gb-wls'
    when 'ga' # Gaelic
      alpha = 'ie'
    when 'af' # Afrikaans
      alpha = 'za'
    end
    "flag-icon-#{alpha}"
  end

  def to_param
    alpha2
  end

  def to_s
    name
  end

  def as_json(options = {})
    unless options[:prefixes].blank?
      options = {
        only: %i[name alpha2 plaques_count],
        include: {},
        methods: []
      }
    end
    super(options)
  end
end
