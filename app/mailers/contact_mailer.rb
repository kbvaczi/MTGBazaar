class ContactMailer < ActionMailer::Base
 
  default :from => "\"Feedback\" <admin@mtgbazaar.com>"

  def send_mail(sender)
    @sender = sender

    mail(:to => "admin@mtgbazaar.com",
         :subject => "Feedback: #{sender.support_type}")
  end
  
end
