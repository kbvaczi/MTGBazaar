class PaymentNotification < ActiveRecord::Base
  
  belongs_to :account_balance_transfer
  serialize :params
  
  after_create :confirm_balance_transfer!
  
  private
  
    def confirm_balance_transfer!
      transfer = self.account_balance_transfer
      
      #transfer type is a deposit
      if transfer.transfer_type == "deposit"
        if self.status == "Completed" && self.params[:secret] == "b4z44r2012!"
          unless transfer.confirmed_at #if deposit is already confirmed don't repeat this
            transfer.update_attribute(:confirmed_at, Time.now) # set balance transfer to confirmed
            transfer.account.balance_credit!(transfer.balance) #add deposit to user's balance
          end 
        end
      end
      
      # transfer type is a withdraw
      if transfer.transfer_type == "withdraw"
        if self.status == "Completed" && self.params[:secret] == "b4z44r2012!"
          unless transfer.confirmed_at # if withdraw is already confirmed don't repeat this
            transfer.update_attribute(:confirmed_at, Time.now)  # set balance transfer to confirmed
            transfer.account.balance_debit!(transfer.balance)   # withdraw from user's balance
          end
        end
      end
      
    end
    
end
