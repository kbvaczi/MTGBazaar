class Email::Queue < GirlFriday::WorkQueue
  include Singleton
  
  def initialize
    super(:mail_queue, :size => 1) do |mail|      
      Rails.logger.info("Email::Queue RUNNING!")
      Mail::SMTP.new(ActionMailer::Base.smtp_settings).deliver!(mail)
      Rails.logger.info("Email::Queue COMPLETE!")      
    end
  end
  
  def self.push *args
    Rails.logger.info("pushed to Email::Queue!")
    instance.push *args
  end

end