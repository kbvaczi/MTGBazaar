class Ticket < ActiveRecord::Base

  belongs_to  :author,        :polymorphic => true
  belongs_to  :transaction,   :polymorphic => true
  belongs_to  :offender,      :class_name  => "User"
  has_many    :updates,       :class_name  => "TicketUpdate"
  
  validate :verify_transaction_number, :verify_offender_username, :normal_users_cannot_set_strikes
  validates_presence_of           :problem, :author_id, :author_type
  validates :description,         :presence => true, 
                                  :length => {:maximum => 1000}  
  after_create :set_ticket_number
  
  # these class variables are accessible to be changed by user when creating a new ticket
  attr_accessible :problem, :offender_username, :transaction_number, :description
  
  # form accepts these parameters which are not actually in the model itself
  attr_accessor :transaction_number, :offender_username, :current_user
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{ticket_number}".parameterize 
  end
  
  # requires user to either 1) submit blank transaction ID, or 2) submit correct transaction ID which is associated with themselves
  def verify_transaction_number
    if (not AdminUser.current_admin_user.present?) and (self.transaction_number.present? or self.transaction_id.present?) # user is not admin, and has entered a transaction ID
      if self.problem == "delivery confirmation"
        transaction = Mtg::Transaction.where(:seller_id => self.current_user.id, :transaction_number => self.transaction_number).first
      else
        transaction = Mtg::Transaction.where(:buyer_id => self.current_user.id, :transaction_number => self.transaction_number).first #find the transaction corresponding to transaction ID entered and which belongs to current user
      end
      if not transaction.present? # did we find the transaction?
        errors.add(:transaction_number, "invalid transaction ID") # transaction ID was entered wrong, or this transaction doesn't belong to current user
      else
        self.transaction = transaction # correct transaction ID entered let's set the transaction
      end
    end
    
    # Verify transaction_number is present if it is needed
    if self.problem == "shipping" or self.problem == "delivery confirmation"
      if not self.transaction_number.present? 
        errors.add(:transaction_number, "Required for this problem type")
      end
    end
    
  end
  
  # validates that user enters a valid username in the offender input
  def verify_offender_username
    # Verify offender valid
    if self.offender_id.present? or self.offender_username.present? # do this only if an offender was entered
      if self.offender_username.present?
        o = User.where("username LIKE ?", self.offender_username).first 
      elsif self.offender_id.present?
        o = User.find(self.offender_id) 
      end
      
      if not o.present?
        errors.add(:offender_username, "Invalid username")
      else
        self.offender = o
      end
    end
    # Verify offender is present if it is needed
    if self.problem == "harassment" or self.problem == "profanity"
      if not self.offender_username.present?
        errors.add(:offender_username, "Required for this problem type")
      end
    end
  end  
  
  # prevents normal users from setting strikes against other users.  only admins can determine strikes
  def normal_users_cannot_set_strikes
    if not AdminUser.current_admin_user.present? # user is not an admin
      errors.add(:strike, "Tickets authored by users cannot assign strikes") if self.strike? # return an error if user somehow entered a strike
    end
  end
  
  # creates a unique ticket number based on ID
  def set_ticket_number
    self.ticket_number = "TKT-#{(self.id + 51235).to_s(36).rjust(5,"0").upcase}"
    self.save
  end
  
  def self.active
    where("status LIKE ? OR status LIKE ?", "new", "under review")
  end
  
  def self.ticket_problem_list
    [["I found profanity or inappropriate content",   "profanity"],
     ["I am being harassed by another user",          "harassment"],
     ["I want to report illegal activity",            "illegal"], 
     ["I discovered a bug I would like to share",     "bug"],                                                                                     
     ["Other problem not covered under FAQ",          "other"]]  
  end
  
  def self.ticket_status_list
    ["open","resolved","closed"]
  end
  
end
