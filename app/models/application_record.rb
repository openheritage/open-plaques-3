# app/models/application_record.rb
require 'nameable'

class ApplicationRecord < ActiveRecord::Base
  include Nameable

  self.abstract_class = true
end
