# This class represents featured plaques, e.g. 'plaque of the day'
# It should hold enough information to be able to rotate the plaque featured
# on the home page to something topical and/or interesting
# === Attributes
# * +description+ - a short blurb on why this one was chosen
# * +feature_on+ - (optional) a specific date to show this plaque, e.g. someone's birthday
# * +last_featured+ - when the plaque was last featured
# * +featured_count+ - number of times the plaque has been featured
# * +proposer+ - who to say proposed it
#
# === Associations
# * Plaque - the plaque to feature
class Pick < ActiveRecord::Base

  belongs_to :plaque

  scope :current, :conditions => ["last_featured > ? and last_featured < ?", (Date.today - 1.day).strftime + " 23:59:59 UTC" , (Date.today + 1.day).strftime + " 00:00:00 UTC"], :order => "last_featured DESC"
  scope :never_been_featured, :conditions => ["last_featured isnull or featured_count = 0 or featured_count isnull"]
  scope :preferably_today, :conditions => ["feature_on > ? and feature_on < ?", (Date.today - 1.day).strftime + " 23:59:59 UTC" , (Date.today + 1.day).strftime + " 00:00:00 UTC"], :order => "featured_count ASC"
  scope :least_featured, :conditions => ["last_featured < ?", Date.today - 1.week], :order => "featured_count ASC"

  validates_presence_of :plaque_id
  validates_uniqueness_of :plaque_id
  
  def self.todays
    @todays = Pick.current.first
    self.rotate unless @todays
    @todays = Pick.current.first
  end
  
  def self.rotate
    @todays = Pick.preferably_today.first
    @todays = Pick.never_been_featured.first if @todays.nil?
    @todays = Pick.least_featured.first if @todays.nil?
    if @todays
      @todays.choose
      @todays.save
    end    
  end

  def choose
    self.last_featured = DateTime.now
    self.featured_count = 0 if self.featured_count == nil
    self.featured_count = self.featured_count + 1
  end

  def title
    "Pick #" + self.id.to_s + " " + self.plaque.title
  end
  
end
