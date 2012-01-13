class DeviseAdminUser < ActiveRecord::Migration
  def up
    add_column :users, :user_level, :int, :default => 0
  end

  def down
    remove_column :users, :user_level
  end
end
