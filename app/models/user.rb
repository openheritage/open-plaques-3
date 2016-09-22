# A registered user of the website
#
# === Attributes
# * +name+ - The full name of the user.
# * +username+ - The user's unique 'username'.
# * +email+ - The user's e-mail address.
class User < ActiveRecord::Base

  belongs_to :todo_item

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  # :registerable, :token_authenticatable, :confirmable, :lockable and :timeoutable
#  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :name, :opted_in
  validates_presence_of :username
  validates_length_of :username, within: 3..40
  validates_uniqueness_of :username
  before_validation :generate_username_and_password_if_not_logged_in

  def generate_username_and_password_if_not_logged_in
    if !self.name.blank? && !self.email.blank? && self.username.blank?
      self.username = Time.now.to_i.to_s
      self.password = rand(99999999999)
      self.password_confirmation = self.password
      self.is_verified = false
    end
  end

end
