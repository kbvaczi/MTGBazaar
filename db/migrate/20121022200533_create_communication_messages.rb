class CreateCommunicationMessages < ActiveRecord::Migration

  def up
    create_table  :communications do |t|
      #foreign keys      
      t.integer   :sender_id
      t.integer   :receiver_id
      t.integer   :mtg_transaction_id

      #table data
      t.text      :message
      t.boolean   :unread,                 :default => true

      t.timestamps      
    end
    
    add_index     :communications, :sender_id
    add_index     :communications, :receiver_id    
    add_index     :communications, :mtg_transaction_id
    
  end

  def down
    drop_table    :communications
  end

end
