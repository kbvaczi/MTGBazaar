class AddActiveToUsers < ActiveRecord::Migration
  def up
    add_column :users, :active, :boolean, :default => true
    remove_column :accounts, :vacation
  end
  
  def down
    add_column :accounts, :vacation, :boolean
    remove_column :users, :active
  end
end
