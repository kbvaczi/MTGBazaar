class Mtg::Transactions::PaymentNotification < ActiveRecord::Base
  self.table_name = 'mtg_transactions_payment_notifications'    
    
  belongs_to :payment,    :class_name => "Mtg::Transactions::Payment"
  serialize  :response
  
end
