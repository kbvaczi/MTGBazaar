class PaymentNotification < ActiveRecord::Base
  
  belongs_to :account_balance_transfer
  serialize :params
  
  after_create :confirm_balance_transfer!
  
  private
  
    def confirm_balance_transfer!
      transfer = self.account_balance_transfer
      
      #transfer type is a deposit
      if transfer.transfer_type == "deposit"
        if self.status == "Completed" && self.params[:secret] == PAYPAL_CONFIG[:secret]
          unless transfer.confirmed_at #if deposit is already confirmed don't repeat this
            transfer.confirmed_at = Time.now 
            transfer.status = "completed"
            transfer.save
            transfer.account.balance_credit!(transfer.balance) #add deposit to user's balance
          end 
        end
      end
      
      # transfer type is a withdraw
      if transfer.transfer_type == "withdraw"
        if self.status == "Completed" && self.params[:secret] == PAYPAL_CONFIG[:secret]
          unless transfer.confirmed_at # if withdraw is already confirmed don't repeat this
            # Confirm user still has enough money in his/her account prior to withdraw
            if transfer.account.balance >= transfer.balance               
              transfer.confirmed_at = Time.now 
              transfer.status = "completed"
              transfer.save
              transfer.account.balance_debit!(transfer.balance)   # withdraw from user's balance
            end
          end
        end
      end
      
    end
    
end
