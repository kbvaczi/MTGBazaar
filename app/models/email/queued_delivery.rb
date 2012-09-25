class Email::QueuedDelivery < Mail::SMTP


  def initialize(values = {})
    # (optional)
    #self.settings = ActionMailer::Base.smtp_settings.merge!(values)
    Rails.logger.debug("QueuedDelivery Method Initialized!")      
  end

  def deliver!(mail)
    Rails.logger.debug("QueuedDelivery Method TRIGGERED!")
    Email::Queue.push(mail)     
  end

end # class QueueDelivery
