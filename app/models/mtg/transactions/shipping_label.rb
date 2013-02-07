class Mtg::Transactions::ShippingLabel < ActiveRecord::Base
  self.table_name = 'mtg_transactions_shipping_labels'    
  
  belongs_to :transaction,  :class_name => "Mtg::Transaction",  :foreign_key => "transaction_id"
  serialize :params
  serialize :tracking
  serialize :to_address
  serialize :from_address
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :price, :transaction, :url, :params, :stamps_tx_id, :tracking, :status
  
  attr_accessor :transaction_number, :postage_created
  
  # ------ CALLBACKS --------- #
  
  before_validation :set_address_information_from_verified_address, :on => :create
  
  def set_address_information_from_verified_address
    this_transaction = Mtg::Transaction.includes(:payment, {:seller => :account}, {:buyer => :account}).where(:id => self.transaction_id).first
    Rails.logger.info("line 28")
    if this_transaction.present?
      Rails.logger.info("transaction Present")      
      self.from_address = build_address(:user => this_transaction.seller, :full_name => this_transaction.seller.username)
      Rails.logger.info("error?")            
      
      gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(         # setup gateway, login to Paypal API
        :pem =>       PAYPAL_CONFIG[:paypal_cert_pem],
        :login =>     PAYPAL_CONFIG[:api_login],
        :password =>  PAYPAL_CONFIG[:api_password],
        :signature => PAYPAL_CONFIG[:api_signature],
        :appid =>     PAYPAL_CONFIG[:appid] )
      
      paypal_address  = gateway.get_shipping_addresses(:pay_key => this_transaction.payment.paypal_paykey).selected_address
      
      self.to_address = { :full_name  =>  paypal_address.addressee_name.blank? ? "#{this_transaction.buyer.account.first_name} #{this_transaction.buyer.account.last_name}" : paypal_address.addressee_name,
                          :first_name =>  this_transaction.buyer.account.first_name,
                          :last_name  =>  this_transaction.buyer.account.last_name,                          
                          :address1   =>  paypal_address.base_address[:line1], 
                          :address2   =>  paypal_address.base_address[:line2], 
                          :city       =>  paypal_address.base_address[:city], 
                          :state      =>  paypal_address.base_address[:state],
                          :country    =>  "US", #only allow US-based addresses for now
                          :zip_code   =>  paypal_address.base_address[:postal_code] }
                              
      #self.to_address = unconfirmed_address.merge!(:override_hash => Stamps.clean_address(:address => unconfirmed_address)[:address][:override_hash])
    end
    
  end
  
  # ------ VALIDATIONS --------- #

  # make sure there's a transaction before doing anything
  validates_presence_of :transaction
  # if there's a transaction, try to buy stamps
  validate              :buy_stamp_if_none_exists, :on => :create, :if => "transaction"
  # after stamp purchase, verify stamp was created properly
  validates_presence_of :price, :url, :params, :stamps_tx_id, :if => "postage_created"
  validates             :price, :numericality => {:greater_than => 0, :less_than => 5000, :message => "Must be between $0.01 and $50"}, :if => "postage_created"   #price must be between $0 and $10,000.00  
  
  
  def self.calculate_shipping_parameters(options = {})
    options = {:card_count => 1, :insurance => false, :item_value => 0.to_money, :signature => false, :shipping_type => 'usps'}.merge(options)
    card_weight_in_oz = (options[:card_count] / 15.to_f) # 15 cards per ounce
    if options[:card_count] <= 150
      service_type = 'US-FC' 
      package_type = 'Package'
      package_weight_in_oz = 1.7
      if options[:card_count] <= 15
        basic_shipping_charge = 1.99.to_money # our cost = 1.64 at 3oz, USPS 2.80 with DC
      elsif options[:card_count] <= 50
        basic_shipping_charge = 2.99.to_money # our cost = 2.15 at 6oz, USPS 3.31 with DC
      elsif options[:card_count] <= 150
        basic_shipping_charge = 3.99.to_money # our cost = 3.28 at 13oz, USPS 4.50 with DC            
      end
    elsif options[:card_count] <= 500
      service_type = 'US-PM' 
      package_type = 'Small Flat Rate Box'
      package_weight_in_oz = 4
      basic_shipping_charge = 5.99.to_money # our cost = 5.15 flat rate, USPS = 6.10 with DC
    elsif options[:card_count] <= 4000
      service_type = 'US-PM' 
      package_type = 'Flat Rate Box'
      package_weight_in_oz = 5
      basic_shipping_charge = 11.99.to_money # our cost = 10.85 flat rate, USPS = 12.10 with DC      
    else
      service_type = 'US-PM' 
      package_type = 'Large Flat Rate Box'
      package_weight_in_oz = 6
      basic_shipping_charge = 13.99.to_money # our cost = 10.85 flat rate, USPS = 14.65 with DC            
    end
    total_weight_in_oz = ((card_weight_in_oz + package_weight_in_oz) * 1.1).round(2) # add up weight, add error margin
    total_weight_in_oz = 3 if total_weight_in_oz <= 3 # flat rate for everything under 3oz, so just round up if so
    shipping_options_pricing = {:basic_shipping         => basic_shipping_charge,
                                :insurance              => Mtg::Transactions::ShippingLabel.insurance_charge(:item_value => options[:item_value].to_money || 0),
                                :signature_confirmation => 2.49.to_money } # our cost for signature confirmation = 2.1, USPS = 2.55
    shipping_options_charges = {:basic_shipping         => options[:shipping_type] == 'usps' ? shipping_options_pricing[:basic_shipping] : 0.to_money,
                                :insurance              => options[:insurance]               ? shipping_options_pricing[:insurance] : nil,
                                :signature_confirmation => options[:signature]               ? shipping_options_pricing[:signature_confirmation] : nil }
    total_shipping_charge = shipping_options_charges.values.inject(0.to_money) { |sum, val| sum + (val || 0.to_money) }
    # paypal requires all purchases over $250 to have signature confirmation
    if total_shipping_charge + options[:item_value] - (shipping_options_charges[:signature_confirmation] || 0.to_money) >= 250.to_money    
      shipping_options_charges[:signature_confirmation] = shipping_options_pricing[:signature_confirmation] 
      total_shipping_charge = shipping_options_charges.values.inject(0.to_money) { |sum, val| sum + (val || 0.to_money) }      
    end
    return {:weight_in_oz             => total_weight_in_oz, 
            :service_type             => service_type, 
            :package_type             => package_type, 
            :shipping_options_pricing => shipping_options_pricing,
            :shipping_options_charges => shipping_options_charges,
            :total_shipping_charge    => total_shipping_charge } 

  end
  
  # returns rate of insurance to charge user, returns nil if we cannot insure the package
  def self.insurance_charge(options = {})
    options = {:item_value => 0.to_money}.merge(options)
    if options[:item_value] > 0.to_money
      if options[:item_value]    <= 50.00.to_money
        return 1.85.to_money
      elsif options[:item_value] <= 100.00.to_money
        return 2.35.to_money
      elsif options[:item_value] <= 200.00.to_money
        return 2.90.to_money        
      elsif options[:item_value] <= 300.00.to_money
        return 4.85.to_money        
      elsif options[:item_value] <= 400.00.to_money
        return 5.95.to_money                
      elsif options[:item_value] <= 500.00.to_money
        return 7.05.to_money 
      elsif options[:item_value] <= 600.00.to_money
        return 8.15.to_money
      elsif options[:item_value] <= 10000.00.to_money
        return (8.15 + ((options[:item_value].to_f / 100).ceil - 6) * 1.10).to_money
      else
        return nil
      end
    else
      return nil
    end
    
    #Insured Value	  Stamps Cost	    Stamps %	    USPS Cost	    USPS %
    #0.1-50	          1.66	          6.64%	        1.85	        7.40%
    #50.1 - 100	      2.11	          2.11%	        2.35	        2.35%
    #100.1 - 200      2.61                          2.90
    #200.1 - 300      4.36                          4.85
    #300.1 - 400      5.35                          5.95
    #400.1 - 500      6.34                          7.05
    #500.1 - 600      7.33                          8.15
    #over 600 for stamps 7.33 + $0.99 for every $100 (rounded up) over $600
    #over 600 for usps   8.15 + $1.10 for every $100 (rounded up) over $600    
    #No insurance over $10000
    
  end
  
  def update_tracking
    if self.status == "active"
      begin
        self.tracking       = Stamps.track(self.stamps_tx_id)
      rescue Exception => message
        Rails.logger.info("ERROR TRACKING: #{message}")
      end
      last_tracking_event = self.tracking_events.first # tracking events are in reverse order (newest first)
      if self.tracking_events.size > 1 && self.transaction.status == "confirmed"
        self.transaction.ship_sale(:shipped_at => (self.tracking_events[-2][:timestamp] rescue Time.zone.now))
        ApplicationMailer.delay(:queue => :email).buyer_shipment_confirmation(self.transaction) # notify buyer that the sale has been shipped
      end
      if last_tracking_event.present? && last_tracking_event[:event].downcase == "delivered"
        self.status = "delivered"
        self.transaction.update_attributes(:seller_delivered_at => (last_tracking_event[:timestamp] rescue Time.zone.now),
                                           :status              => 'delivered')
      end
      if defined?(message) and message.present?
        return false
      else
        return self.save
      end
    else
      return false
    end
  end
  
  def tracking_events
    # if the tracking event object is a hash, there is only one tracking event...
    if self.tracking.present? && self.tracking[:tracking_events].present? && self.tracking[:tracking_events][:tracking_event].class == Hash 
      [ self.tracking[:tracking_events][:tracking_event] ] 
    # if the tracking event object is an array, there are multiple tracking events...  
    elsif self.tracking.present? && self.tracking[:tracking_events].present? && self.tracking[:tracking_events][:tracking_event].class == Array    
      self.tracking[:tracking_events][:tracking_event] 
    # no tracking info, return empty array
    else
      [] 
    end
  end
  
  def refund
    begin
      # stamp must be older than 2 weeks old and not mailed yet
      if self.status == "active" and self.created_at < 2.weeks.ago
        Stamps.refund(self.stamps_tx_id)
        return true
      else
        return false
      end
    rescue
      return false
    end
  end
  
  protected
  
  def buy_stamp_if_none_exists
    if not transaction.present?
      self.errors[:base] << "No transaction..."
      postage_created = false      
    elsif transaction.shipping_label.present?
      self.errors[:base] << "Shipping label already exists..."
      postage_created = false
    else
      postage_created = true      
      # old implimentation before verified address 
      #from_address = build_address(:user => transaction.seller, :full_name => transaction.seller.username)
      #to_address   = build_address(:user => transaction.buyer)
      create_stamp(:from          => self.from_address, 
                   :to            => self.to_address, 
                   :stamps_tx_id  => transaction.transaction_number,
                   :certified     => false,
                   :insurance     => false,
                   :item_value => '0')               
    end
    #TODO: Code insurance and certified mail algorithms
  end

  def build_address(options={})
    a = {
      :full_name     => options[:full_name].present? ? options[:full_name] : "#{options[:user].account.first_name} #{options[:user].account.last_name}" ,
      :first_name    => options[:user].account.first_name,
      :last_name     => options[:user].account.last_name,
      :address1      => options[:user].account.address1,
      :address2      => options[:user].account.address2,                  
      :city          => options[:user].account.city,
      :state         => options[:user].account.state,
      :zip_code      => options[:user].account.zipcode,
      :cleanse_hash  => (options[:user].account.address_verification[:cleanse_hash] rescue ""),
      :override_hash => (options[:user].account.address_verification[:override_hash] rescue "")   
    }
    options[:clean] == true ? Stamps.clean_address(:address => a)[:address] : a
  end
  
  def create_stamp(options={})
    details = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters(:card_count => transaction.cards_quantity)
    stamp = Stamps.create!({
               :sample          => STAMPS_CONFIG[:running_mode] == "production" ? false : true,  # all labels are test labels if we aren't in production mode....
               :image_type      => "Pdf",
               :customer_id     => self.transaction.seller.username,
               :transaction_id  => options[:stamps_tx_id],
               :to              => options[:to],
               :from            => options[:from],
               :memo            => options[:memo] || "MTGBazaar.com",
               :rate            => {
                 :from_zip_code   => options[:from][:zip_code],
                 :to_zip_code     => options[:to][:zip_code],
                 :weight_oz       => details[:weight_in_oz],
                 :ship_date       => (Date.today).strftime('%Y-%m-%d'),
                 :package_type    => details[:package_type],
                 :service_type    => details[:service_type],
                 :insured_value   => self.transaction.value.dollars,
                 :add_ons         => { :add_on => determine_add_ons }
               }
            })
    self.params = stamp
    self.stamps_tx_id = stamp[:stamps_tx_id]
    self.price = stamp[:rate][:amount].to_money + stamp[:rate][:add_ons][:add_on_v2].inject(0.to_money) {|sum, addon| sum + (addon[:amount].to_money rescue 0.to_money) }
    buy_postage_if_necessary(:current_balance => stamp[:postage_balance][:available_postage].to_i, 
                             :control_total   => stamp[:postage_balance][:control_total].to_i)
  end
  
  def determine_add_ons
    add_on_array        = []
    transaction_add_ons = self.transaction.shipping_options[:shipping_charges]
    if transaction_add_ons[:signature_confirmation].present?
      add_on_array << { :type => 'US-A-SC' }  # Signature Confirmation      
      add_on_array << { :type => 'SC-A-HP' }  # Hidden Postage
    elsif transaction_add_ons[:certified].present?
      add_on_array << { :type => 'US-A-CM' }  # Certified Mail      
    else
      add_on_array << { :type => 'US-A-DC' }  # Delivery Confirmation
      add_on_array << { :type => 'SC-A-HP' }  # Hidden Postage      
    end
    add_on_array << { :type => 'SC-A-INS' } if transaction_add_ons[:insurance].present? # Insurance
    add_on_array
  end

  # buy postage if balance is below minimum (only works in STAMPS_CONFIG[:running_mode] = production)
  def buy_postage_if_necessary(options = {:current_balance => 9999, :control_total => 0})
    min_postage_balance     = 25   # buy postage if balance is under this amount
    postage_purchase_amount = 75   # amount to purchase at a time
    max_control_total       = 1000 # max amount to spend per month?
    if STAMPS_CONFIG[:running_mode] == "production" || true 
      if options[:current_balance] < min_postage_balance && options[:control_total] < max_control_total
          Rails.logger.info("STAMPS: Postage below #{min_postage_balance}, attempting to purchase #{postage_purchase_amount} in postage")
          begin 
            response = Stamps.purchase_postage(:amount => postage_purchase_amount,
                                               :control_total => options[:control_total])
            if response[:purchase_status] == "Rejected"
              Rails.logger.info("STAMPS: Postage purchase FAILED!, Rejection reason: #{response[:rejection_reason]}")
            else
              Rails.logger.info("STAMPS: Postage purchase SUCCESS!")          
              Rails.cache.write "stamps_last_purchased_postage_at", Time.zone.now rescue nil
              Rails.cache.write "stamps_current_balance", response[:postage_balance][:available_postage] rescue nil
            end                                               
          rescue Exception => message
            Rails.logger.info("STAMPS PURCHASE POSTAGE ERROR MESSAGE: #{message}")
          end                                            
      else
        Rails.logger.info("STAMPS: Checking Postage Balance: #{options[:current_balance]}")          
      end
    else
       Rails.logger.info("STAMPS: We don't buy postage in test mode")          
    end
  end

end