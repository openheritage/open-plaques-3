class GoogleAnalytic < ApplicationRecord
  belongs_to :record, polymorphic: true, touch: true
end
