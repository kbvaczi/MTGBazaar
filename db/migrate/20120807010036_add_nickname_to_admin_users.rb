class AddNicknameToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :string, :nickname

  end
end
