class ApplicationMailer < ActionMailer::Base
 
  default :from => "\"MTGBazaar Notifications\" <admin@mtgbazaar.com>"

  def send_sale_notification(recipient, transaction) #recipient is a User object
    @recipient = recipient
    @transaction = transaction
    mail(:to => recipient.email, :subject => "Pending sale to #{recipient.username}" ) 
  end
  
end