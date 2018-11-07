# A provision of funds or permission to erect a commemorative plaque
# such that the organisation often has its name displayed on the plaque
# === Attributes
class Sponsorship < ApplicationRecord
  belongs_to :plaque
  belongs_to :organisation, counter_cache: true
end
