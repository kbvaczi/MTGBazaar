class User < ActiveRecord::Base
  # database relationships
  has_one :account, :dependent => :destroy

  # Include default devise modules. Others available are:
  #:token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  # :account_attributes allows nested model support for account while editing form for user
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :account_attributes
  
  # allow form for accounts nested inside user signup/edit forms
  accepts_nested_attributes_for :account
  
  # validations
  validates_presence_of :username, :email
  
  # username must be between 3 and 15 characters and can only have letters, numbers, dash, period, or underscore (no other special characters)
  validates             :username,  :length => { :minimum => 3, :maximum   => 15 },
                                    :format => { :with => /\A[\w\d]+\z/, :message => "no special characters"}

  # validates account model when user model is saved
  validates_associated :account
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{username}".parameterize 
  end

  # build an account for this user object if it does not already have one
  def with_account
    self.build_account if !self.account
    self
  end
  
end
