class Mtg::Transactions::PaymentNotification < ActiveRecord::Base
  self.table_name = 'mtg_transactions_payment_notifications'    
    
  belongs_to :payment,    :class_name => "Mtg::Transactions::Payment"
  serialize  :response
  
  # validations
  validates_presence_of :payment_id, :response, :status, :paypal_transaction_id
  
  # callbacks
  after_create :process_transaction
  
  def process_transaction  
    if self.status == "completed" &&  self.response[:transaction_type] == "Adaptive Payment PAY" # check to see if payment was successful and verify this is not a refund
      self.payment.transaction.order.checkout_transaction if self.payment.transaction.order.present?
      self.payment.transaction.update_attribute(:transaction_number, self.paypal_transaction_id)
      self.payment.update_attributes(:status => "completed")      
    end
  end
  
end

=begin
EXAMPLE PAYMENT NOTIFICATION
{"transaction"=>{"0"=>{".is_primary_receiver"=>"true", ".id_for_sender_txn"=>"5CK461120M538633D", ".receiver"=>"darnovo@gmail.com", ".amount"=>"USD 8.11", ".status"=>"Completed", ".id"=>"10E76772L5815154J", ".status_for_sender_txn"=>"Completed", ".paymentType"=>"GOODS", ".pending_reason"=>"NONE"}, 
                 "1"=>{".paymentType"=>"SERVICE", ".id_for_sender_txn"=>"1HT11975JB173294G", ".is_primary_receiver"=>"false", ".status_for_sender_txn"=>"Completed", ".receiver"=>"paypal@mtgbazaar.com", ".amount"=>"USD 2.29", ".pending_reason"=>"NONE", ".id"=>"2HS2402730411235R", ".status"=>"Completed"}}, 
 "log_default_shipping_address_in_transaction"=>"false", "action_type"=>"PAY", "ipn_notification_url"=>"https://mtgbazaar.herokuapp.com/transactions/1041/payment_notification?cart_id=1401&secret=E1zM%2FkQ6V7hy8YtxPqu6JoG4GS85d0tG0cUecje%2FfXQ%3D%0A", "charset"=>"windows-1252", "transaction_type"=>"Adaptive Payment PAY", "notify_version"=>"UNVERSIONED", "cancel_url"=>"https://mtgbazaar.herokuapp.com/orders/231/checkout_failure", "verify_sign"=>"A--8MSCLabuvN8L.-MHjxC9uypBtAHmhze0.Si1Zt9vvf-G0yO58P9VQ", "sender_email"=>"kvaczi2@gmail.com", "fees_payer"=>"PRIMARYRECEIVER", "return_url"=>"https://mtgbazaar.herokuapp.com/orders/231/checkout_success?secret=E1zM%2FkQ6V7hy8YtxPqu6JoG4GS85d0tG0cUecje%2FfXQ%3D%0A", "memo"=>"Purchase of 3 item(s) from user darnovo on MTGBazaar.com", "reverse_all_parallel_payments_on_error"=>"false", "pay_key"=>"AP-3NP44661Y3569935E", "status"=>"COMPLETED", "payment_request_date"=>"Tue Oct 30 16:30:40 PDT 2012", "cart_id"=>"1401", "secret"=>"E1zM/kQ6V7hy8YtxPqu6JoG4GS85d0tG0cUecje/fXQ=\n", "controller"=>"mtg/transactions/payment_notifications", "action"=>"payment_notification", "id"=>"1041"}

EXAMPLE REFUND PAYMENT NOTIFICATION

{"transaction"=>{"0"=>{".is_primary_receiver"=>"true", ".id_for_sender_txn"=>"5CK461120M538633D", ".receiver"=>"darnovo@gmail.com", ".amount"=>"USD 8.11", ".status"=>"Completed", ".id"=>"10E76772L5815154J", ".status_for_sender_txn"=>"Completed", ".paymentType"=>"GOODS", ".pending_reason"=>"NONE"}, 
                 "1"=>{".paymentType"=>"SERVICE", ".id_for_sender_txn"=>"1HT11975JB173294G", ".refund_amount"=>"USD 2.29", ".is_primary_receiver"=>"false", ".refund_account_charged"=>"paypal@mtgbazaar.com", ".status_for_sender_txn"=>"Refunded", ".receiver"=>"paypal@mtgbazaar.com", ".amount"=>"USD 2.29", ".refund_id"=>"26424121M79520530", ".pending_reason"=>"NONE", ".id"=>"2HS2402730411235R", ".status"=>"Refunded"}}, 
 "log_default_shipping_address_in_transaction"=>"false", "action_type"=>"PAY", "ipn_notification_url"=>"https://mtgbazaar.herokuapp.com/transactions/1041/payment_notification?cart_id=1401&secret=E1zM%2FkQ6V7hy8YtxPqu6JoG4GS85d0tG0cUecje%2FfXQ%3D%0A", "charset"=>"windows-1252", "transaction_type"=>"Adjustment", "notify_version"=>"UNVERSIONED", "reason_code"=>"Refund", "cancel_url"=>"https://mtgbazaar.herokuapp.com/orders/231/checkout_failure", "verify_sign"=>"AwD4sJJmdrzDKNGw7KMAMuZSx1AHAvGIw-BKNVeYNgmUJri2ponVIHuB", "sender_email"=>"kvaczi2@gmail.com", "fees_payer"=>"PRIMARYRECEIVER", "return_url"=>"https://mtgbazaar.herokuapp.com/orders/231/checkout_success?secret=E1zM%2FkQ6V7hy8YtxPqu6JoG4GS85d0tG0cUecje%2FfXQ%3D%0A", "memo"=>"Purchase of 3 item(s) from user darnovo on MTGBazaar.com", "reverse_all_parallel_payments_on_error"=>"false", "pay_key"=>"AP-3NP44661Y3569935E", "status"=>"COMPLETED", "payment_request_date"=>"Tue Oct 30 16:30:40 PDT 2012", "cart_id"=>"1401", "secret"=>"E1zM/kQ6V7hy8YtxPqu6JoG4GS85d0tG0cUecje/fXQ=\n", "id"=>"1041"}

EXAMPLE REFUND PAYMENT WITH CREDIT CARD

{"transaction"=>{"0"=>{".is_primary_receiver"=>"true", ".id_for_sender_txn"=>"1L10086554012712T", ".receiver"=>"darnovo@gmail.com", ".amount"=>"USD 15.27", ".status"=>"Completed", ".id"=>"8HR06296JC136511V", ".status_for_sender_txn"=>"Completed", ".paymentType"=>"GOODS", ".pending_reason"=>"NONE"}, 
                 "1"=>{".paymentType"=>"SERVICE", ".id_for_sender_txn"=>"3VT32341GA139145C", ".refund_amount"=>"USD 2.29", ".is_primary_receiver"=>"false", ".refund_account_charged"=>"paypal@mtgbazaar.com", ".status_for_sender_txn"=>"Refunded", ".receiver"=>"paypal@mtgbazaar.com", ".amount"=>"USD 2.29", ".refund_id"=>"6TA31523S6542253D", ".pending_reason"=>"NONE", ".id"=>"5JH12153X56061256", ".status"=>"Refunded"}}, 
                 "log_default_shipping_address_in_transaction"=>"false", "action_type"=>"PAY", "ipn_notification_url"=>"https://mtgbazaar.herokuapp.com/transactions/1081/payment_notification?cart_id=1431&secret=SQSGd1w5VwpFXmFZA8xgZr4CtVRx%2BKr%2Bf%2B2U%2Fs%2B1Bsc%3D%0A", "charset"=>"windows-1252", "transaction_type"=>"Adjustment", "notify_version"=>"UNVERSIONED", "reason_code"=>"Refund", "cancel_url"=>"https://mtgbazaar.herokuapp.com/orders/241/checkout_failure", "verify_sign"=>"An5ns1Kso7MWUdW4ErQKJJJ4qi4-AiTJ794VSUDjY4y0YlZmgN0VtMQS", "sender_email"=>"kvaczi2@gmail.com", "fees_payer"=>"PRIMARYRECEIVER", "return_url"=>"https://mtgbazaar.herokuapp.com/orders/241/checkout_success?secret=SQSGd1w5VwpFXmFZA8xgZr4CtVRx%2BKr%2Bf%2B2U%2Fs%2B1Bsc%3D%0A", "memo"=>"Purchase of 1 item(s) from user darnovo on MTGBazaar.com", "reverse_all_parallel_payments_on_error"=>"false", "pay_key"=>"AP-39J24992WK180790B", "status"=>"COMPLETED", "payment_request_date"=>"Tue Oct 30 17:56:40 PDT 2012", "cart_id"=>"1431", "secret"=>"SQSGd1w5VwpFXmFZA8xgZr4CtVRx+Kr+f+2U/s+1Bsc=\n", "id"=>"1081"}

=end