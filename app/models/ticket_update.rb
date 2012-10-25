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
    if self.author_type != "AdminUser" and self.complete_ticket?
      errors.add(:complete_ticket, "Users cannot complete tickets")
    end
  end
  
  def add_strike_to_ticket_if_strike
    if self.author_type == "AdminUser" and self.strike == "1"
      self.ticket.update_attribute(:strike, true) 
    end
  end
  
  def update_ticket_status
    if self.author_type == "AdminUser"
      if self.complete_ticket
        # close the ticket and cut off communication from the user
        self.ticket.update_attribute(:status, "closed")
      elsif self.ticket.status == "open"
        # ticket status goes to resolved once an admin responds
        self.ticket.update_attribute(:status, "resolved")
      end
    elsif self.ticket.status == "resolved"
      # users adding updates after status set to resolved re-opens ticket
      self.ticket.update_attribute(:status, "open")
    end
  end
end
