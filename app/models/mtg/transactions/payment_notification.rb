class Mtg::Transactions::PaymentNotification < ActiveRecord::Base
  self.table_name = 'mtg_transactions_payment_notifications'    
    
  belongs_to :payment,    :class_name => "Mtg::Transactions::Payment"
  serialize  :response
  
  # validations
  validates_presence_of :payment_id, :response, :status, :paypal_transaction_id
  
  # callbacks
  after_create :process_transaction
  
  def process_transaction  
    if self.status == "completed"                              # check to see if payment was successful
      # self.payment.transaction.order.checkout_transaction if self.payment.transaction.order.present?
      self.payment.transaction.update_attribute(:transaction_number, self.paypal_transaction_id)
      self.payment.update_attributes(:status => "completed")      
    end
  end
  
end
