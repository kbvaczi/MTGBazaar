class CreateTickets < ActiveRecord::Migration

  def up
    create_table :tickets do |t|
      # foreign keys
      t.integer   :transaction_id                               # tickets can refer to more than one type of transactions (to be implemented once we expand past just MTG)
      t.string    :transaction_type                             # the type of transaciton referenced, most likely MtgTransaction until we expand past MTG
      t.integer   :author_id                                    # the person submitting the ticket, can be User or AdminUser
      t.string    :author_type                                  # User or AdminUser
      t.integer   :offender_id,          :default => nil        # the person referenced by the ticket doing something bad (if applicable). This will always be a User since Admins won't be written up for anything... we hope...

      # class variables  
      t.string    :problem,              :default => ""         # "abuse"             - offender is abusing the system in some way
                                                                # "profanity"         - offender has used profanity
                                                                # "harassment"        - offender is harassing another user
                                                                # "shipping"          - shipment has not arrived
                                                                # "other"             - some other reason not covered under FAQ
      t.text      :description,          :default => ""
      t.string    :ticket_number,        :default => ""
      t.string    :status,               :default => "new"      # "new" , "under review", "resolved"
      t.boolean   :strike,               :default => false      # does this ticket constitute a strike against the offender?
      t.timestamps
    end

    # Table Indexes
    add_index :tickets, :transaction_id
    add_index :tickets, :transaction_type    
    add_index :tickets, :author_id
    add_index :tickets, :author_type    
    add_index :tickets, :offender_id            
  end

  def down
    drop_table :tickets    
  end
  
end