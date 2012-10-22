class ContactMailer < ActionMailer::Base
 
  default :from => "\"Feedback\" <noreply@mtgbazaar.com>"

  def send_mail(sender)
    @sender = sender

    mail(:to => "feedback@mtgbazaar.com",
         :subject => "Feedback: #{sender.support_type}")
  end
  
end
