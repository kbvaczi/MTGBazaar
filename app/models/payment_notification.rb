class PaymentNotification < ActiveRecord::Base
  
  belongs_to :account_balance_transfer
  serialize :params
  
  after_create :confirm_balance_transfer!
  
  private
  
    def confirm_balance_transfer!
      if self.status == "Completed" && self.params[:secret] == "b4z44r2012!"
        deposit = self.account_balance_transfer
        unless deposit.confirmed_at #if deposit is already confirmed don't repeat this
          self.account_balance_transfer.update_attribute(:confirmed_at, Time.now) # set balance transfer to confirmed
          self.account_balance_transfer.account.balance_credit!(account_balance_transfer.balance) #add deposit to user's balance
        end 
      end
    end
    
end
