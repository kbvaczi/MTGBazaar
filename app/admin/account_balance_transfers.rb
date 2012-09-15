ActiveAdmin.register AccountBalanceTransfer do
  menu :label => "2 --- Balance Transfers", :parent => "Users"
  
  # ------ ACTION ITEMS (BUTTONS) ------- #  
  
  config.clear_action_items! #clear standard buttons
  action_item :only => :show do
    # process withdraws link for withdraws
    if account_balance_transfer.confirmed_at == nil && account_balance_transfer.transfer_type == "withdraw"
      # oops, the user has not enough money for this withdraw now, maybe they bought some stuff after submitting the original request
      if account_balance_transfer.balance > account_balance_transfer.account.balance
        'Insufficient Funds to Process Withdraw'
      else
        link_to 'Process Withdraw', approve_withdraw_admin_account_balance_transfer_path(account_balance_transfer), :method => :put 
      end
    end
  end    

  # ------ INDEX PAGE CUSTOMIZATIONS ----- #
  
  scope :all, :default => true do |bts|
    bts.includes(:payment_notifications, :account => :user)
  end
  scope :deposits do |bts|     
    bts.includes(:payment_notifications, :account => :user).where(:transfer_type => "deposit")
  end
  scope :withdraws do |bts|
    bts.includes(:payment_notifications, :account => :user).where(:transfer_type => "withdraw")
  end
  scope "Pending Withdraws" do |bts|
    bts.includes(:payment_notifications, :account => :user).where(:transfer_type => "withdraw", :confirmed_at => nil)
  end  

  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |bts|
      link_to bts.id, admin_account_balance_transfer_path(bts)
    end
    column :transfer_type, :sortable => :transfer_type do |bts|
      bts.transfer_type
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
  
  # ------ FILTER FORM CUSTOMIZATIONS --------------------- #
  
  
  # ------ CONTROLLER ACTIONS ------- #
  
  # note: collection_actions work on collections, member_acations work on individual  
  member_action :approve_withdraw, :method => :put do
    extend ActionView::Helpers::NumberHelper  # needed for number_to_currency  
    
    withdraw = AccountBalanceTransfer.find(params[:id])
    
    # confirm user still has enough money in his/her account to withdraw
    if withdraw.balance < withdraw.account.balance
      
      # set balance transfer status to confirmed
      withdraw.update_attribute(:approved_at, Time.now) if withdraw.approved_at == nil

      # setup transaction
      gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(
        :pem =>       PAYPAL_CONFIG[:paypal_cert_pem],
        :login =>     PAYPAL_CONFIG[:api_login],
        :password =>  PAYPAL_CONFIG[:api_password],
        :signature => PAYPAL_CONFIG[:api_signature],
        :appid =>     PAYPAL_CONFIG[:appid] )

      recipients = [ {:email => "#{withdraw.account.paypal_username}",
                      :invoice_id => "01-#{withdraw.id}",
                      :amount => withdraw.balance.dollars } ]

      purchase = gateway.setup_purchase(
        :action_type          => "CREATE",
        :return_url           => root_url,
        :cancel_url           => root_url,
        :ipn_notification_url => create_withdraw_notification_url(:secret => PAYPAL_CONFIG[:secret]),  
        :sender_email         => PAYPAL_CONFIG[:account_email],
        :memo                 => "#{withdraw.account.user.username}: Withdraw of #{number_to_currency(withdraw.balance.dollars)}",
        :receiver_list        => recipients )

      # execute transaction
      gateway.execute_payment(purchase)
      
      #withdraw.reload #refresh withdraw variable since it may have changed
      
      if withdraw.confirmed_at != nil
        flash[:notice] = "Transaction Completed..."
      else
        flash[:error]  = "Potential Transaction Error... See Payment Notification for details..."
      end
    
    else
      
      flash[:error] = "User has insufficient funds for withdraw..."
    
    end
    
    respond_to do |format|
      format.html { redirect_to admin_account_balance_transfers_path }
    end
    
  end
  
end
