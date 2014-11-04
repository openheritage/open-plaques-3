class Page < ActiveRecord::Base

  validates_presence_of :name, :slug, :body
  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /^[a-z\_]+$/, :message => "can only contain lowercase letters and underscores"


end
