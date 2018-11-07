# A page of text from a very simple CMS
# === Attributes
# * +body+ - The content
# * +name+ - The name of the page
# * +slug+ - An identifier for the organisation, usually equivalent to its name in lower case, with spaces replaced by underscores. Used in URLs.
# * +strapline+ - A sub heading
class Page < ApplicationRecord
  before_validation :make_slug_not_war
  validates_presence_of :name, :slug, :body
  validates_uniqueness_of :slug
  validates_format_of :slug, with: /\A[a-z\_]+\z/, message: "can only contain lowercase letters and underscores"

  include ApplicationHelper

  def to_s
  	name
  end

end
