# This class is a page of text from a very simple CMS
# === Attributes
# * +name+ - The name of the page
# * +slug+ - An identifier for the organisation, usually equivalent to its name in lower case, with spaces replaced by underscores. Used in URLs.
# * +body+ - The content
class Page < ActiveRecord::Base

  validates_presence_of :name, :slug, :body
  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /\A[a-z\_]+\z/, :message => "can only contain lowercase letters and underscores"

  def to_s
  	name
  end
  
end
