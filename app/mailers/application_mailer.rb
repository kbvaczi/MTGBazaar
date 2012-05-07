class ApplicationMailer < ActionMailer::Base
  
  helper "mtg::cards"
  
  default :from => "\"MTGBazaar Notifications\" <admin@mtgbazaar.com>"


  def send_buyer_checkout_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Purchase request #{@transaction.transaction_number}" ) 
  end

  def send_seller_sale_notification(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.seller    
    mail(:to => @recipient.email, :subject => "Pending sale #{@transaction.transaction_number}" ) 
  end

  def send_seller_shipping_information(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.seller
    mail(:to => @recipient.email, :subject => "Shipping information #{@transaction.transaction_number}" ) 
  end

  def send_buyer_sale_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Purchase confirmation #{@transaction.transaction_number}" ) 
  end

  def send_buyer_shipment_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Shipment confirmation #{@transaction.transaction_number}" ) 
  end  
  
  def send_buyer_sale_rejection(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Purchase rejection #{@transaction.transaction_number}" ) 
  end  

end