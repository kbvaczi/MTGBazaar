class User < ActiveRecord::Base
# ---------------- MODEL SETUP ----------------
  
  # database relationships
  has_one  :account,                  :dependent => :destroy
  has_one  :statistics,               :class_name => "UserStatistics",            :foreign_key => "user_id",        :dependent => :destroy
  has_one  :cart
  has_many :communications_sent,      :class_name => "Communication",             :foreign_key => "sender_id",      :dependent => :destroy
  has_many :communications_received,  :class_name => "Communication",             :foreign_key => "receiver_id",    :dependent => :destroy  
  has_many :mtg_listings,             :class_name => "Mtg::Cards::Listing",       :foreign_key => "seller_id"
  has_many :mtg_purchases,            :class_name => "Mtg::Transaction",          :foreign_key => "buyer_id"
  has_many :mtg_purchase_items,       :class_name => "Mtg::Transactions::Item",   :through => :mtg_purchases,       :source => :items
  has_many :mtg_sales,                :class_name => "Mtg::Transaction",          :foreign_key => "seller_id"
  has_many :mtg_sale_items,           :class_name => "Mtg::Transactions::Item",   :through => :mtg_sales,           :source => :items
  has_many :tickets,                  :class_name => "Ticket",                    :as => "author"                         # tickets authored by this person... polymorpic relationship (author can either be User or AdminUser)
  has_many :tickets_about,            :class_name => "Ticket",                    :foreign_key => "offender_id"           # tickets written about this person... not polymorphic (offender can only be User)
  

  # Include default devise modules. Others available are:
  #:token_authenticatable, :encryptable, :confirmable, :lockable, :rememberable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  # :account_attributes allows nested model support for account while editing form for user
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :account_attributes, :terms, :age
  
  # not-in-model fields for age and agree-to-terms fields in sign-up
  attr_accessor :terms
  cattr_accessor :current_user
  
  # allow form for accounts nested inside user signup/edit forms
  accepts_nested_attributes_for :account, :statistics

  # override default route to add username in route.
  def to_param
    "#{id}-#{username}".parameterize 
  end
  
# ---------------- CALLBACKS ----------------      

  after_create   :create_statistics
  after_update   :update_statistics_when_active_changed, :if => "active_changed?"

  def create_statistics
    self.statistics = UserStatistics.create
  end
  
  def update_statistics_when_active_changed
    self.mtg_listings.each { |l| l.update_statistics_cache_on_save }
    if self.active
      self.statistics.update_listings_mtg_cards_count if self.statistics.present?
    else
      self.statistics.update_attribute(:listings_mtg_cards_count, 0) if self.statistics.present?
    end
  end
  
# ---------------- VALIDATIONS ----------------      
  
  # validates that age and terms have been checked on user sign-up only
  validates :terms, :inclusion => {:in => [["1",""]], :message => "please accept terms to continue"}, :on => :create
  
  # multiple users cannot have the same username
  validates_uniqueness_of :username, :case_sensitive => false, :message => "This username has already been taken"
  validates_uniqueness_of :email,    :case_sensitive => false
  
  # username must be between 3 and 15 characters and can only have letters, numbers, dash, period, or underscore (no other special characters)
  validates             :username,  :length    => { :minimum => 3, :maximum   => 15, :message => "Username must be at least 3 characters" },
                                    :format    => { :with    => /\A[\w]+\z/, :message => "No spaces or special characters please"}
  validates             :username,  :format    => { :with    => /\A[[A-Z][a-z]]{3,}/, :message => "Username must start with at least 3 letters"}
  
  validate              :username_not_reserved, :on => :create
  #validates             :username,  :exclusion => { :in      => eval("["+SiteVariable.get("reserved_usernames")+"]"), :message => "is reserved, please contact us for details" }, :on => :create
  
  # validates account model when user model is saved
  validates_associated :account, :statistics
  
  validate              :active_false_when_no_paypal_information
  
  def username_not_reserved
    reserved_usernames = eval("[" + SiteVariable.get("reserved_usernames") + "]")
    reserved_usernames.each do |reserved_username| 
      errors.add(:username, "Username is reserved, please contact us for details") if self.username.include? reserved_username
    end
  end
  
  def active_false_when_no_paypal_information
    if self.active && self.account.present? && !self.account.paypal_username.present?
      self.active = false
    end
  end
  
# ---------------- MEMBER METHODS -------------

  # build an account for this user object if it does not already have one
  def with_account
    self.build_account if !self.account  
    self
  end
  
  def ship_option_pickup_available?
    false
  end
  
  def pending_purchases
    Mtg::Transaction.where(:buyer_id => id, :status => "pending")
  end
  
  def active_purchases
    Mtg::Transaction.where(:buyer_id => id).where("status <> \'delivered\' AND status <> \'cancelled\' AND status <> \'rejected\'")
  end  
  
  def pending_sales
    Mtg::Transaction.where(:seller_id => id, :status => "pending")
  end
  
  def active_sales
    self.mtg_sales.where("status <> \'completed\'")
  end
  
  
# ------------  SCOPES --------------------
  
  def self.active
    where(:banned => false, :active => true)
  end

end
