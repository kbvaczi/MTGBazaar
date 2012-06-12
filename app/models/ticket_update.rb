class TicketUpdate < ActiveRecord::Base

  belongs_to  :author,        :polymorphic => true
  belongs_to  :ticket
  
  validate :validate_user_cannot_close_ticket
  validates_presence_of :description, :author_id, :author_type, :ticket_id
  
  # these class variables are accessible to be changed by user when creating a new ticket update
  attr_accessible :description
  attr_accessor   :strike
  
  after_create { |ticket_update| ticket_update.ticket.touch }
  after_create :add_strike_to_ticket_if_strike, :update_ticket_status
  
  def validate_user_cannot_close_ticket
    if not AdminUser.current_admin_user.present? and self.complete_ticket?
      errors.add(:complete_ticket, "Users cannot complete tickets")
    end
  end
  
  def add_strike_to_ticket_if_strike
    if AdminUser.current_admin_user.present? and self.strike == "1"
      self.ticket.update_attribute(:strike, true) 
    end
  end
  
  def update_ticket_status
    if AdminUser.current_admin_user.present?
      if self.complete_ticket
        self.ticket.update_attribute(:status, "complete")
      elsif self.ticket.status == "new"
        self.ticket.update_attribute(:status, "under review")
      end
    end
  end
end
