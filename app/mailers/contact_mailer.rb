class ContactMailer < ActionMailer::Base
 
  default :from => "\"MTGBazaar\" <noreply@mtgbazaar.com>"

  def send_mail(sender)
    @sender = sender

    mail(:to => "CustomerService@mtgbazaar.com",
         :subject => "Contact Form: #{sender.support_type}")
  end
  
end
