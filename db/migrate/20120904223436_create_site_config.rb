class CreateSiteConfig < ActiveRecord::Migration
  def up
    create_table :site_variables do |t|
      #foreign keys(none)      
      
      #table data
      t.string    :name
      t.text      :value
      t.datetime  :start_at
      t.datetime  :end_at
      t.boolean   :active,      :default => true
      t.timestamps
      
    end
      #indexes
      add_index :site_variables, :name
      add_index :site_variables, :active
      
  end
  
  def down
    drop_table :site_variables
    
  end
  
end
