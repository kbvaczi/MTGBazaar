class ApplicationMailer < ActionMailer::Base
 
  default :from => "\"MTGBazaar Notifications\" <admin@mtgbazaar.com>"

  def send_seller_sale_notification(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.seller    
    mail(:to => @recipient.email, :subject => "Pending sale to #{@transaction.buyer.username}" ) 
  end

  def send_seller_shipping_information(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.seller
    mail(:to => @recipient.email, :subject => "Shipping information for #{@transaction.buyer.username}" ) 
  end

  def send_buyer_sale_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Purchase confirmation from #{@transaction.seller.username}" ) 
  end  
  
  def send_buyer_sale_rejection(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Purchase rejection from #{@transaction.seller.username}" ) 
  end  

end