# A registered user of the website
# === Attributes
# * +username+ - unique identifier
# * +name+ - full name
# * +email+ - e-mail address
# * +crypted_password+ - [used by Devise]
# * +salt+ - [used by Devise]
# * +created_at+
# * +updated_at+
# * +remember_token_expires_at+ - [used by Devise]
# * +is_admin+ - whether they have superpowers
# * +encrypted_password+ - [used by Devise]
# * +reset_password_token+ - [used by Devise]
# * +remember_created_at+ - [used by Devise]
# * +sign_in_count+ - [used by Devise]
# * +current_sign_in_at+ - [used by Devise]
# * +last_sign_in_at+ - [used by Devise]
# * +current_sign_in_ip+ - [used by Devise]
# * +last_sign_in_ip+ - [used by Devise]
# * +is_verified+ - [used by Devise]
# * +opted_in+ - [used by Devise]
# * +reset_password_sent_at+ - [used by Devise]
class User < ApplicationRecord

  belongs_to :todo_item, optional: true

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  # :registerable, :token_authenticatable, :confirmable, :lockable and :timeoutable
#  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :name, :opted_in
  validates_presence_of :username
  validates_length_of :username, within: 3..40
  validates_uniqueness_of :username
#  before_validation :generate_username_and_password_if_not_logged_in

#  def generate_username_and_password_if_not_logged_in
#    if !self.name.blank? && !self.email.blank? && self.username.blank?
#      self.username = Time.now.to_i.to_s
#      self.password = rand(99999999999)
#      self.password_confirmation = self.password
#      self.is_verified = false
#    end
#  end

end
