class Ticket < ActiveRecord::Base

  belongs_to  :author,        :polymorphic => true
  belongs_to  :transaction,   :polymorphic => true
  belongs_to  :offender,      :class_name  => "User"
  has_many    :updates,       :class_name  => "TicketUpdate"
  
  validate :verify_transaction_number, :verify_offender_username, :normal_users_cannot_set_strikes
  validates_presence_of :description, :problem, :author_id, :author_type
  after_create :set_ticket_number
  
  # these class variables are accessible to be changed by user when creating a new ticket
  attr_accessible :problem, :offender_username, :transaction_number, :description
  
  # form accepts these parameters which are not actually in the model itself
  attr_accessor :transaction_number, :offender_username
  
  # requires user to either 1) submit blank transaction number, or 2) submit correct transaction number which is associated with themselves
  def verify_transaction_number
    if (not AdminUser.current_admin_user.present?) and (self.transaction_number.present? or self.transaction_id.present?) # user is not admin, and has entered a transaction number
      if self.problem == "delivery confirmation"
        transaction = Mtg::Transaction.where(:seller_id => User.current_user.id, :transaction_number => self.transaction_number).first
      else
        transaction = Mtg::Transaction.where(:buyer_id => User.current_user.id, :transaction_number => self.transaction_number).first #find the transaction corresponding to transaction number entered and which belongs to current user
      end
      if not transaction.present? # did we find the transaction?
        errors.add(:transaction_number, "invalid transaction number") # transaction number was entered wrong, or this transaction doesn't belong to current user
      else
        self.transaction = transaction # correct transaction number entered let's set the transaction
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
      offender = User.where("username LIKE ?", self.offender_username).first if self.offender_username.present?
      offender = User.find(self.offender_id) if not self.offender_username.present?
      if not offender_username.present?
        errors.add(:offender_username, "Invalid username")
      else
        self.offender_id = offender.id
      end
    end
    # Verify offender is present if it is needed
    unless self.problem == "shipping" or self.problem == "delivery confirmation" or self.problem == "other"
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
end
