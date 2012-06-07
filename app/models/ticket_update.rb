class TicketUpdate < ActiveRecord::Base

  belongs_to  :author,        :polymorphic => true
  belongs_to  :ticket
  
  validate :validate_user_cannot_close_ticket
  validates_presence_of :description, :author_id, :author_type, :ticket_id
  
  # these class variables are accessible to be changed by user when creating a new ticket update
  attr_accessible :description
  attr_accessor   :strike
  
  after_create { |ticket_update| ticket_update.ticket.touch }
  
  def validate_user_cannot_close_ticket
    if not AdminUser.current_admin_user.present? and self.complete_ticket?
      errors.add(:complete_ticket, "Users cannot complete tickets")
    end
  end
end
