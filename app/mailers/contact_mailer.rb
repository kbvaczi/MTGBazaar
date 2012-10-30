class ContactMailer < ActionMailer::Base
 
  default :from => "\"MTGBazaar\" <noreply@mtgbazaar.com>"

  def send_mail(sender)
    @sender = sender

    mail(:to => "feedback@mtgbazaar.com",
         :subject => "#{sender.support_type}")
  end
  
end
