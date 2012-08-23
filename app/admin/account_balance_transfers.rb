ActiveAdmin.register AccountBalanceTransfer do
  menu :label => "Balance Transfers", :parent => "Users"
  
  # ------ ACTION ITEMS (BUTTONS) ------- #  
  
  begin
    config.clear_action_items! #clear standard buttons
    action_item :only => :show do
      link_to 'Approve Withdraw', approve_withdraw_admin_account_balance_transfer_path(account_balance_transfer), :method => :put if account_balance_transfer.approved_at == nil
    end    
  end

  # ------ INDEX PAGE CUSTOMIZATIONS ----- #
  
  scope :deposits, :default => true do |bts|
    bts.includes(:account => :user).where(:transfer_type => "deposit")
  end
  scope :withdraws do |bts|
    bts.includes(:account => :user).where(:transfer_type => "withdraw")
  end
  scope "Pending Withdraws" do |bts|
    bts.includes(:account => :user).where(:transfer_type => "withdraw").where(:approved_at => nil)
  end  

  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |bts|
      link_to bts.id, admin_account_balance_transfer_path(bts)
    end
    column :balance, :sortable => :balance do |bts|
      number_to_currency(bts.balance)
    end
    column "User", :sortable => :'users.username' do |bts|
      bts.account.user.username
    end
    column :created_at
    column :approved_at
    column :confirmed_at
    column :updated_at    
  end

  # ------ CONTROLLER ACTIONS ------- #
   # note: collection_actions work on collections, member_acations work on individual  
    member_action :approve_withdraw, :method => :put do
      @withdraw = AccountBalanceTransfer.find(params[:id])
      @withdraw.update_attribute(:approved_at, Time.now)
      respond_to do |format|
        format.html { redirect_to admin_account_balance_transfers_path, :notice => "Withdraw Approved..."}
      end
    end
  
end
