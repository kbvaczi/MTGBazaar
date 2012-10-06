class Mtg::Transactions::PaymentNotification < ActiveRecord::Base
  
  belongs_to :payment,    :class_name => "Mtg::Transactions::Payment"
  serialize  :response
  
end
