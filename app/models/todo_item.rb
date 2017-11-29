# This class represents a to do item. It has a type (e.g. transcribe a photo, geo-tag a plaque). Maybe this needs its own class?
# a description, a user (who completed the task)
# an optional plaque that needs something doing to it
# an optional url for more details (e.g. a news article about an unveiling)
# and optional image url to show in the to do lists
# === Attributes
# * +description+ - details of what needs doing.
# * +action+ - type of action required (adding a plaque, geo-tagging, transcribing etc.)
# * +url+ - url with more information. Optional
# * +image_url+ - picture to show with the todo item. Optional.
# * +plaque_id+ - plaque referred to. Optional.
# * +user_id+ - [not used]
# * +created_at+
# * +updated_at+
class TodoItem < ApplicationRecord

  validates_presence_of :action, :description
  scope :to_add, -> { where(action: 'add').where.not(url: nil) }
  scope :to_datacapture, -> { where(action: 'datacapture').where.not(url: nil) }

  def to_datacapture?
    false
	  true if action == 'datacapture'
  end

end
