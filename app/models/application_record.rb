# app/models/application_record.rb
require 'nameable'

# application record, every model object inherits this
class ApplicationRecord < ActiveRecord::Base
  include Nameable

  self.abstract_class = true
  has_many :google_analytics, as: :record
  scope :random, ->(l = 1) { l > 1 ? order(Arel.sql('random()')).limit(l) : order(Arel.sql('random()')).limit(l).first }
end
