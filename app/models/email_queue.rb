class EmailQueue < GirlFriday::WorkQueue
  include Singleton
  
  def initialize
    super(:email_queue, :size => 5) do |options|
      case options[:template]
        when "account_update_notification"
          ApplicationMailer.account_update_notification(options[:data]).deliver
        when "buyer_checkout_confirmation"          
          ApplicationMailer.buyer_checkout_confirmation(options[:data]).deliver          
        when "buyer_sale_confirmation"
          ApplicationMailer.buyer_sale_confirmation(options[:data]).deliver                    
        when "buyer_sale_rejection"
          ApplicationMailer.buyer_sale_rejection(options[:data]).deliver          
        when "buyer_shipment_confirmation"
          ApplicationMailer.buyer_shipment_confirmation(options[:data]).deliver          
        when "buyer_cancellation_notice"
          ApplicationMailer.buyer_cancellation_notice(options[:data]).deliver          
        when "seller_sale_notification"
          ApplicationMailer.seller_sale_notification(options[:data]).deliver          
        when "seller_shipping_information"
          ApplicationMailer.seller_shipping_information(options[:data]).deliver          
      end
    end
  end
  
  def self.push *args
    instance.push *args
  end

end