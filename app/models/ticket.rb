class Ticket < ActiveRecord::Base

  belongs_to  :author,        :polymorphic => true
  belongs_to  :transaction,   :polymorphic => true
  belongs_to  :offender,      :class_name  => "User"
  
  validate :verify_transaction_number, :verify_offender_username, :normal_users_cannot_set_strikes
  validates_presence_of :description, :problem
  
  # these class variables are accessible to be changed by user when creating a new ticket
  attr_accessible :problem, :offender, :transaction_number, :description
  
  # form accepts these parameters which are not actually in the model itself
  attr_accessor :transaction_number, :offender
  cattr_accessor :current_user
  
  # requires user to either 1) submit blank transaction number, or 2) submit correct transaction number which is associated with themselves
  def verify_transaction_number
    if (not AdminUser.current_admin_user.present?) and (self.transaction_number.present? or self.transaction_id.present?) # user is not admin, and has entered a transaction number
      transaction = Mtg::Transaction.where(:buyer_id => User.current_user.id, :transaction_number => self.transaction_number).first #find the transaction corresponding to transaction number entered and which belongs to current user
      if not transaction.present? # did we find the transaction?
        errors.add(:transaction_number, "invalid transaction number") # transaction number was entered wrong, or this transaction doesn't belong to current user
      else
        self.transaction = transaction # correct transaction number entered let's set the transaction
      end
    end
  end
  
  # validates that user enters a valid username in the offender input
  def verify_offender_username
    offender = User.where("username LIKE ?", self.offender).first
    if not offender.present?
      errors.add(:offender, "invalid username")
    else
      self.offender_id = offender.id
    end
  end  
  
  # prevents normal users from setting strikes against other users.  only admins can determine strikes
  def normal_users_cannot_set_strikes
    if not AdminUser.current_admin_user.present? # user is not an admin
      errors.add(:strikes, "error-strikes") if self.strike? # return an error if user somehow entered a strike
    end
  end
end
