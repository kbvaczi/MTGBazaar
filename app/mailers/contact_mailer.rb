class ContactMailer < ActionMailer::Base
 
  default :from => "kvaczi2@gmail.com"
 
  def send_mail(sender)
    @sender = sender

    mail(:to => "kvaczi2@gmail.com",
         :subject => "Feedback: #{sender.support_type}")
  end
  
end
