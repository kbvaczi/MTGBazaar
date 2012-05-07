class User < ActiveRecord::Base
# ---------------- MODEL SETUP ----------------
  
  # database relationships
  has_one  :account, :dependent => :destroy
  has_one  :cart
  has_many :mtg_listings,       :class_name => "Mtg::Listing",              :foreign_key => "seller_id"
  has_many :mtg_purchases,      :class_name => "Mtg::Transaction",          :foreign_key => "buyer_id"
  has_many :mtg_purchase_items, :class_name => "Mtg::TransactionItem",      :foreign_key => "buyer_id"  
  has_many :mtg_sales,          :class_name => "Mtg::Transaction",          :foreign_key => "seller_id"
  has_many :mtg_sale_items,     :class_name => "Mtg::TransactionItem",      :foreign_key => "seller_id"
  has_many :mtg_problems,       :class_name => "Mtg::TransactionIssue",     :foreign_key => "author_id"

  # Include default devise modules. Others available are:
  #:token_authenticatable, :encryptable, :confirmable, :lockable, :rememberable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  # :account_attributes allows nested model support for account while editing form for user
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :account_attributes, :age, :terms
  
  # not-in-model fields for age and agree-to-terms fields in sign-up
  attr_accessor :age, :terms
  cattr_accessor :current_user
  
  # allow form for accounts nested inside user signup/edit forms
  accepts_nested_attributes_for :account
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{username}".parameterize 
  end

# ---------------- VALIDATIONS ----------------      
  
  # validates that age and terms have been checked on user sign-up only
  validates :age, :terms, :inclusion => {:in => [["","1"]]}, :on => :create
  
  # validations
  validates_presence_of   :username, :email
  
  # multiple users cannot have the same username
  validates_uniqueness_of :username, :email, :case_sensitive => false
  
  # username must be between 3 and 15 characters and can only have letters, numbers, dash, period, or underscore (no other special characters)
  validates             :username,  :length => { :minimum => 3, :maximum   => 15 },
                                    :format => { :with => /\A[-_\w\d]+\z/, :message => "no special characters please"}

  # validates account model when user model is saved
  validates_associated :account
  
# ---------------- MEMBER METHODS -------------

  # build an account for this user object if it does not already have one
  def with_account
    self.build_account if !self.account
    self
  end
  
  def pending_transactions
    Mtg::Transaction.where(:buyer_id => id, :seller_confirmed_at => nil)
  end
  
  def active_transactions
    Mtg::Transaction.where(:buyer_id => id).where("seller_confirmed_at IS NOT NULL")
  end  
  

end
