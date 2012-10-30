class ApplicationMailer < ActionMailer::Base
  layout 'email'
  
  helper "mtg::cards"
  
  default :from => "\"MTGBazaar Notification\" <noreply@mtgbazaar.com>"

  def account_update_notification(user)
    @user = user
    mail(:to => user.email, :subject => "Account Information Change")
  end

  def buyer_checkout_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    mail(:to => @transaction.buyer.email, :subject => "Purchase request: #{@transaction.transaction_number}" ) 
  end

  def seller_sale_notification(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    mail(:to => @transaction.seller.email, :subject => "Pending sale: #{@transaction.transaction_number}" ) 
  end

  def buyer_shipment_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    mail(:to => @transaction.buyer.email, :subject => "Shipment confirmation: #{@transaction.transaction_number}" ) 
  end  

end