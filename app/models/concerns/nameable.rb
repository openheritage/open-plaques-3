# has a 'name' attribute
module Nameable
  extend ActiveSupport::Concern

  included do
    scope :name_starts_with, ->(term) { where(['lower(name) LIKE ?', "#{term.to_s.downcase}%"]) }
    scope :name_contains, ->(term) { where(['lower(name) LIKE ?', "%#{term.to_s.downcase}%"]) }
    scope :name_is, ->(term) { where(['lower(name) = ?', term.to_s.downcase]) }
    scope :alphabetically, -> { order(name: :asc) }
  end
end
