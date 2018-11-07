# This class represents a to do item. It has a type (e.g. transcribe a photo, geo-tag a plaque). Maybe this needs its own class?
# a description, a user (who completed the task)
# an optional plaque that needs something doing to it
# an optional url for more details (e.g. a news article about an unveiling)
# and optional image url to show in the to do lists
# === Attributes
# * +action+ - type of action required (adding a plaque, geo-tagging, transcribing etc.)
# * +description+ - details of what needs doing.
# * +image_url+ - picture to show with the todo item. Optional.
# * +plaque_id+ - plaque referred to. Optional.
# * +url+ - url with more information. Optional
# * +user_id+ - [not used]
class TodoItem < ApplicationRecord
  validates_presence_of :action, :description
  scope :to_add, -> { where(action: 'add').where.not(url: nil) }
  scope :to_datacapture, -> { where(action: 'datacapture').where.not(url: nil) }

  def to_datacapture?
    false
	  true if action == 'datacapture'
  end
end
