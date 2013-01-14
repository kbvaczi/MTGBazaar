ActiveAdmin.register User do
  
  menu :label => "2 - Standard Users", :parent => "Users"

  # Create sections on the index screen
  #scope :all, :default => true
  
  scope :all, :default => true do |users|
    users.includes [:account, :statistics]
  end
  scope :active do |users|
    users.includes(:account, :statistics).where("users.active = ?", true)
  end
  scope :inactive do |users|
    users.includes(:account, :statistics).where("users.active = ?", false)
  end  

  # Filterable attributes on the index screen
  filter :username
  filter :created_at

  config.clear_action_items!
  action_item :only => :show do
    link_to "Edit User", edit_admin_user_path(user)
  end
  action_item :only => :show do 
    if user.banned?
      link_to "Un-ban User", ban_admin_user_path(user), :method => :post, :confirm => "Are you sure you want to UN-ban #{user.username}?" 
    else 
      link_to "Ban User", ban_admin_user_path(user), :method => :post, :confirm => "Are you sure you want to ban #{user.username}?" 
    end
  end
  action_item :only => :show do
    if user.active
      link_to "Set User Inactive", toggle_active_admin_user_path(user), :method => :post, :confirm => "Are you sure you want to set #{user.username} Inactive?" 
    else 
      link_to "Set User Active", toggle_active_admin_user_path(user), :method => :post, :confirm => "Are you sure you want to set #{user.username} Active?" 
    end
  end

  # Customize columns displayed on the index screen in the table
  index do
    column :username, :sortable => :username do |user|
      link_to user.username, admin_user_path(user.id)
    end
    column "Name", :sortable => :'accounts.last_name' do |user|
      "#{user.account.last_name}, #{user.account.first_name} "
    end  
    column :email
    column "PayPal Email", :sortable => :'accounts.paypal_username' do |user|
      
      if user.account.paypal_username.present?
          status_tag "Yes", :ok
        else
          status_tag "No", :error
      end      
    end 
    column "Current Sign-in", :current_sign_in_at
    #column "Last Sign-in", :last_sign_in_at
    column "Cards Listed", :sortable => "user_statistics.listings_mtg_cards_count" do |user|
      user.statistics.listings_mtg_cards_count
    end
    column "Sales", :sortable => "user_statistics.number_sales" do |user|
      user.statistics.number_sales
    end
    column "Feedback", :sortable => "user_statistics.approval_percent" do |user|
      user.statistics.display_approval_percent
    end    
    column "Strikes", :sortable => "user_statistics.number_strikes" do |user|
      user.statistics.number_strikes
    end
    column "Banned?", :sortable => :banned do |user|
      if user.banned?
        status_tag "Banned", :error
      else
        status_tag "No", :ok
      end
    end
    column "Locked?", :sortable => :locked_at do |user|
      if user.locked_at.nil?
        status_tag "No", :ok
      else
        status_tag "Locked", :error
      end
    end
    column "Active?", :sortable => :'user.active' do |user|
      if user.active
          status_tag "Yes", :ok
        else
          status_tag "No", :error
      end
    end
  end
  
  show :title => :username do |user|
    columns do 
      column do
        panel "User Info" do 
          attributes_table_for user do 
            row :id
            row :username
            row :email
            row :unconfirmed_email            
            row :created_at
            row :sign_in_count
            row :failed_attempts
            row :locked_at
            row :banned
            row "Strikes" do 
              user.statistics.number_strikes
            end
            row :confirmed_at
            row :confirmation_sent_at
            row :confirmation_token
            row :reset_password_token
            row :reset_password_sent_at
            row "security_question" do
              user.account.security_question
            end
            row "security answer" do
              user.account.security_answer
            end            
          end
        end
      end
      column do
        panel "Account Info" do
          attributes_table_for user.account do 
            row :first_name
            row :last_name
            row :address1
            row :address2  
            row :country
            row :state
            row :city
            row :zipcode
          end    
        end
        panel "Seller Info" do
          attributes_table_for user.account do 
            row :paypal_username
            row :commission_rate
            row "Seller Status" do
              user.active
            end
          end
        end  
      end
    end
    
    panel "Login History" do
      render :partial => 'login_history', :locals => {:statistics => user.statistics}
    end
  end
  
  #customize user edit form
  form do |f|
    f.inputs "User Details" do
      f.input :username
      f.input :email
    end
    f.inputs "Account Info" do
      f.semantic_fields_for :account do |ff|
        ff.inputs :first_name, :last_name, :address1, :address2, :city, :state, :zipcode
      end
    end
    f.buttons
  end
  
  #turns off mass assignment when editing so that you can edit protected fields
  controller do
    with_role :admin
    def update_resource(object, attributes)
      object.update_attributes(attributes[0], :without_protection => true)
    end
  end
  
  #custom action to ban users
  member_action :ban, :method => :post do
    user = User.find(params[:id])
    if user.banned?
      user.update_attribute(:banned, false)
      redirect_to admin_user_path(user), :notice => "Un-Banned! We have mercy... sometimes."
    else
      user.update_attribute(:banned, true)
      redirect_to admin_user_path(user), :notice => "Banned! Take that!"
    end
  end
  
  member_action :toggle_active, :method => :post do 
    user = User.find(params[:id])    
    user.active = !user.active
    user.save
    redirect_to admin_user_path(user), :notice => "User set to #{user.active ? "active" : "inactive"}"
  end

  
end
