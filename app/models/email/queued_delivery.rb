class Email::QueuedDelivery < Mail::SMTP

  def initialize(values = {})
    #self.settings = ActionMailer::Base.smtp_settings.merge!(values)      
  end

  def deliver!(mail)
    Email::Queue.push(mail)     
  end

end # class QueuedDelivery
