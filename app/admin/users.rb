ActiveAdmin.register User do
  
  # Create sections on the index screen
  #scope :all, :default => true
  
  scope :all, :default => true do |users|
    users.includes [:account]
  end

  # Filterable attributes on the index screen
  filter :username
  filter :created_at

  # Customize columns displayed on the index screen in the table
  index do
    column :username, :sortable => :username do |user|
      link_to user.username, admin_user_path(user)
    end
    column "Name", :sortable => :'accounts.last_name' do |user|
      "#{user.account.last_name}, #{user.account.first_name} "
    end  
    column :email    
    column "balance", :sortable => :'accounts.balance' do |user|
      number_to_currency user.account.balance / 100 #balance is in cents
    end
    column "Rating", :sortable => :'accounts.average_rating' do |user|
      user.account.average_rating
    end
    column "Sales", :sortable => :'accounts.number_sales' do |user|
      user.account.number_sales
    end    
    column "Purchases", :sortable => :'accounts.number_purchases' do |user|
      user.account.number_purchases
    end
    column "Current Sign-in", :current_sign_in_at
    column "Last Sign-in", :last_sign_in_at
    column "Banned?", :sortable => :banned do |user|
      if user.banned?
        "no"
      else
        "yes"
      end
    end
    column "Locked?", :sortable => :locked_at do |user|
      if user.locked_at.nil?
        "no"
      else
        "yes"
      end
    end
    column "Vacation?", :sortable => :'accounts.vacation' do |user|
      if user.account.vacation?
        "yes"
      else
        "no"
      end
    end
  end
  
  show :title => :username do |user|
    attributes_table_for user do 
      row :username
      row :email
      row :created_at
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :sign_in_count
      row :failed_attempts
      row :locked_at
      row :banned
    end
    attributes_table_for user.account do 
      row :first_name
      row :last_name
      row :address1
      row :address2  
      row :country
      row :state
      row :city
      row :zipcode
      row :balance
      row :number_sales
      row :number_purchases
      row :vacation
      row :average_rating
    end    
  end
  
  #turns off mass assignment when editing so that you can edit protected fields
  #NOT WORKING CURRENTLY
  controller do
    def update 
      super
      #user = User.find(params[:id])      
      #user.update_attribute(:banned, params[:user][:banned])
      #redirect_to admin_user_path(user), :notice => "Updated!"      
    end
  end
  
  #custom action to ban users
  #NOT CURRENTLY USED
  member_action :ban, :method => :put do
    user = User.find(params[:id])
    user.update_attribute(:banned, user.banned)
    redirect_to admin_user_path(user), :notice => "Locked!"
  end

  
end
