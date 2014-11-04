# This class represents registered users of the website
#
# === Attributes
# * +name+ - The full name of the user.
# * +username+ - The user's unique 'username'.
# * +email+ - The user's e-mail address.
#
# === Associations
# * +plaques+ - The plaques that this user added to the site.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable #, :registerable

  # Setup accessible (or protected) attributes for your model
#  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :name, :opted_in
# see http://stackoverflow.com/questions/17371334/how-is-attr-accessible-used-in-rails-4

  has_many :plaques

  validates_presence_of     :username
  validates_length_of       :username,    :within => 3..40
  validates_uniqueness_of   :username

  belongs_to :todo_item

  before_validation :generate_username_and_password_if_not_logged_in

  def make_admin
    self.is_admin = true
    self.save!
  end

  def generate_username_and_password_if_not_logged_in
    if !self.name.blank? && !self.email.blank? && self.username.blank?
      self.username = Time.now.to_i.to_s
      self.password = rand(99999999999)
      self.password_confirmation = self.password
      self.is_verified = false
    end
  end

end
