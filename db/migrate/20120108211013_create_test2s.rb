class CreateTest2s < ActiveRecord::Migration
  def up
    create_table :test2s do |t|
      t.string  :value
      t.timestamps
    end
  end
  
  def down
     drop_table :test2s
  end
end
