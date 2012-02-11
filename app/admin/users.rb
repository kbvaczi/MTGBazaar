ActiveAdmin.register User do
  
  # Create sections on the index screen
  scope :all, :default => true

  # Filterable attributes on the index screen
  filter :username
  filter :created_at

  # Customize columns displayed on the index screen in the table
  index do
    column :username
    column :email
    column "Current Sign-in", :current_sign_in_at
    column :user_level
    column "Failed Sign-ins" , :failed_attempts
    column :sign_in_count

    default_actions
  end
  
end
