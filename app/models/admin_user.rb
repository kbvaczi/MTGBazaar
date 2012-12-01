class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :trackable, :validatable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :nickname, :password_confirmation, :remember_me

  # allow models to access current_admin_user variable using AdminUser.current_admin_user
  cattr_accessor :current_admin_user
  
  # send password request email once added in admin panel
  after_create { |admin| admin.send_reset_password_instructions }

  has_many :news_feeds, :class_name => "NewsFeed", :foreign_key => "author_id"
  
  # password not required on creation.. instead an email will be sent prompting for password creation
  def password_required?
    new_record? ? false : super
  end
  
  def username
    self.email.gsub(/@[a-zA-z0-9.]+/,"").capitalize
  end
  
  def self.members
    where("nickname <> \'admin\'")
  end
  
end
