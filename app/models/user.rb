class User < ActiveRecord::Base
  #database relationships
  has_one :account, :dependent => :destroy

  # Include default devise modules. Others available are:
  #:token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  # :account_attributes allows nested model support for account while editing form for user
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :account_attributes
  
  #allow form for accounts nested inside user signup/edit forms
  accepts_nested_attributes_for :account
  
  #override default route to add username in route.
  def to_param
    "#{id}-#{username}".parameterize 
  end
  
  def with_account
    self.build_account if !self.account
    self
  end
  
end
