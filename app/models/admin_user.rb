class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable, :rememberable, and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  # send password request email once added in admin panel
  after_create { |admin| admin.send_reset_password_instructions }

  # password not required on creation.. instead an email will be sent prompting for password creation
  def password_required?
    new_record? ? false : super
  end
  
end
