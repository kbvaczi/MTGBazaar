class Mtg::Transactions::ShippingLabelQueue < GirlFriday::WorkQueue
  include Singleton
  
  def initialize
    super(:shipping_label_queue, :size => 2) do |options|
      Rails.logger.info("ShippingLabelQueue RUNNING!")
      Rails.logger.info("Attempting to create shipping_label for transaction #{options[:transaction].id}")
      label = Mtg::Transactions::ShippingLabel.new(:transaction => options[:transaction])
      if label.save
        Rails.logger.info("shipping_label CREATED")
      else
        Rails.logger.info("ERRORS: #{label.errors.full_messages}")
      end          
    end
  end
  
  def self.push *args
    instance.push *args
  end

end