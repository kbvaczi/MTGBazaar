class AddNicknameToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :nickname, :string

  end
end
