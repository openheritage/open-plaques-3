# This class represents a to do item. It has a type (e.g. transcribe a photo, geo-tag a plaque). Maybe this needs its own class?
# a description, a user (who completed the task)
# an optional plaque that needs something doing to it
# an optional url for more details (e.g. a news article about an unveiling)
# and optional image url to show in the to do lists


# === Attributes
# * +description+ - Details of what needs doing.
# * +action+ - The type of action required (adding a plaque, geo-tagging, transcribing etc.)
# * +url+ - A url with more information. Optional
# * +image_url+ - A picture to show with the todo item. Optional.
#
# === Associations
# * Plaque - The plaque to be altered. Optional.
# * User - User who completed the item. Optional.

class TodoItem < ActiveRecord::Base

  validates_presence_of :action, :description

  scope :to_add, :conditions => ["action = 'add' AND url IS NOT NULL"]
  scope :to_datacapture, :conditions => ["action = 'datacapture' AND url IS NOT NULL"]
  
  def to_datacapture?
    false
	true if action == 'datacapture'
  end

end