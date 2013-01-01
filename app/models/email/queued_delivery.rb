class Email::QueuedDelivery < Mail::SMTP

  def initialize(values = {})
    #self.settings = ActionMailer::Base.smtp_settings.merge!(values)      
  end

  def deliver!(mail)
    
  end

end # class QueuedDelivery
