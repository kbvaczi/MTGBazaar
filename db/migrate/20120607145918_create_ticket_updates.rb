class CreateTicketUpdates < ActiveRecord::Migration

  def up
    
    create_table :ticket_updates do |t|  
      # foreign keys
      t.integer   :ticket_id                                    # ticket this update is referring to
      t.integer   :author_id                                    # the person submitting the ticket, can be User or AdminUser
      t.string    :author_type                                  # "User" or "AdminUser"

      # class variables  
      t.string    :description,          :default => ""
      t.boolean   :complete_ticket,      :default => false      # does this ticket update close the parent ticket?
      t.timestamps      
    end

    # Table Indexes
    add_index :ticket_updates, :ticket_id
    add_index :ticket_updates, :author_id
    add_index :ticket_updates, :author_type    
    
  end

  def down
    drop_table :ticket_updates  
  end
  
end