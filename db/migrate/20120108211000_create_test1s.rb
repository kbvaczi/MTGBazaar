class CreateTest1s < ActiveRecord::Migration
  def up
    create_table :test1s do |t|

      t.integer :user_id
      
      t.string  :value

      t.timestamps
    end
  end
  def down
     drop_table :test1s
  end
  
end
