ActiveAdmin.register AccountBalanceTransfer do
  menu :label => "Balance Transfers", :parent => "Users"
  

  
  # ------ ACTION ITEMS (BUTTONS) ------- #  
  
  config.clear_action_items! #clear standard buttons
  action_item :only => :show do
    link_to 'Process Withdraw', approve_withdraw_admin_account_balance_transfer_path(account_balance_transfer), :method => :put if account_balance_transfer.confirmed_at == nil && account_balance_transfer.transfer_type == "withdraw"
  end    

  # ------ INDEX PAGE CUSTOMIZATIONS ----- #
  
  scope :deposits, :default => true do |bts|
    bts.includes(:account => :user).where(:transfer_type => "deposit")
  end
  scope :withdraws do |bts|
    bts.includes(:account => :user).where(:transfer_type => "withdraw")
  end
  scope "Pending Withdraws" do |bts|
    bts.includes(:account => :user).where(:transfer_type => "withdraw").where(:confirmed_at => nil)
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
    column "Transaction ID", :sortable => false do |bts|
      bts.payment_notifications.first.transaction_id rescue ""
    end    
  end

  # ------ CONTROLLER ACTIONS ------- #
  # note: collection_actions work on collections, member_acations work on individual  
  member_action :approve_withdraw, :method => :put do
    extend ActionView::Helpers::NumberHelper  # needed for number_to_currency  
    
    withdraw = AccountBalanceTransfer.find(params[:id])
    withdraw.update_attribute(:approved_at, Time.now) if withdraw.approved_at == nil

    ActiveMerchant::Billing::Base.mode = :test

    gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(
      :login => "seller_1345565383_biz_api1.mtgbazaar.com",
      :password => "7FL9R6VGEJUFPRRC",
      :signature => "AFcWxV21C7fd0v3bYYYRCpSSRl31APzCuXjYJP4WEZKAx1jkHS4lX331",
      :appid => "APP-80W284485P519543T" )

    recipients = [ {:email => "#{withdraw.account.paypal_username}",
                    :invoice_id => withdraw.id,
                    :amount => withdraw.balance.dollars } ]

    purchase = gateway.setup_purchase(
      :action_type => "CREATE",
      :return_url => root_url,
      :cancel_url => root_url,
      :ipn_notification_url => create_withdraw_notification_url(:secret => "b4z44r2012!"),  
      :sender_email    => "seller_1345565383_biz@mtgbazaar.com",
      :memo => "#{withdraw.account.user.username}: Withdraw of #{number_to_currency(withdraw.balance.dollars)}",
      :receiver_list => recipients )

    gateway.execute_payment(purchase)

    sleep(10.seconds) # wait for transaction to be processed by paypal
    
    withdraw = AccountBalanceTransfer.find(params[:id]) #refresh withdraw variable since it may have changed
    if withdraw.confirmed_at != nil
      flash[:notice] = "Transaction Completed..."
    else
      flash[:error]  = "Potential Transaction Error... See Payment Notification for details..."
    end
    
    respond_to do |format|
      format.html { redirect_to admin_account_balance_transfers_path }
    end
    
  end
  
end
