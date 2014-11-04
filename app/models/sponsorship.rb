# This class represents the provision of funds or permission to erect a commemorative Plaque
# such that the organisation has its name displayed on the plaque
# === Associations
# * Plaque - the plaque on which this commemoration occurs.
# * Organisation - the organisation that provided funds or permission
class Sponsorship < ActiveRecord::Base
  belongs_to :plaque
  belongs_to :organisation, :counter_cache => true
end
