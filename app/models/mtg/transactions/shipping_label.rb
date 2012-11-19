class Mtg::Transactions::ShippingLabel < ActiveRecord::Base
  self.table_name = 'mtg_transactions_shipping_labels'    
  
  belongs_to :transaction,  :class_name => "Mtg::Transaction",  :foreign_key => "transaction_id"
  serialize :params
  serialize :tracking  
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :price, :transaction, :url, :params, :stamps_tx_id, :tracking, :status
  
  attr_accessor :transaction_number, :postage_created
  
  # validations

  # make sure there's a transaction before doing anything
  validates_presence_of :transaction
  # if there's a transaction, try to buy stamps
  # validate              :buy_postage_if_necessary, :if => "transaction"
  validate              :buy_stamp_if_none_exists, :if => "transaction"
  # after stamp purchase, verify stamp was created properly
  validates_presence_of :price, :url, :params, :stamps_tx_id, :if => "postage_created"
  validates             :price, :numericality => {:greater_than => 0, :less_than => 5000, :message => "Must be between $0.01 and $50"}, :if => "postage_created"   #price must be between $0 and $10,000.00  
  
  
  def self.calculate_shipping_parameters(options = {:card_count => 1})
    card_weight_in_oz = (options[:card_count] / 15.to_f) # 15 cards per ounce
    if options[:card_count] <= 150
      service_type = 'US-FC' 
      package_type = 'Package'
      package_weight_in_oz = 1.7
      if options[:card_count] <= 15
        user_charge = 1.99.to_money # our cost = 1.64 at 3oz, USPS 2.80 with DC
      elsif options[:card_count] <= 50
        user_charge = 2.99.to_money # our cost = 2.15 at 6oz, USPS 3.31 with DC
      elsif options[:card_count] <= 150
        user_charge = 3.99.to_money # our cost = 3.28 at 13oz, USPS 4.50 with DC            
      end 
    elsif options[:card_count] <= 500
      service_type = 'US-PM' 
      package_type = 'Small Flat Rate Box'
      package_weight_in_oz = 4
      user_charge = 5.99.to_money # our cost = 5.15 flat rate, USPS = 6.10 with DC
    elsif options[:card_count] <= 4000
      service_type = 'US-PM' 
      package_type = 'Flat Rate Box'
      package_weight_in_oz = 5
      user_charge = 11.99.to_money # our cost = 10.85 flat rate, USPS = 12.10 with DC      
    else
      service_type = 'US-PM' 
      package_type = 'Large Flat Rate Box'
      package_weight_in_oz = 6
      user_charge = 13.99.to_money # our cost = 10.85 flat rate, USPS = 14.65 with DC            
    end
    total_weight_in_oz = ((card_weight_in_oz + package_weight_in_oz) * 1.1).round(2) # add up weight, add error margin
    total_weight_in_oz = 3 if total_weight_in_oz <= 3 # flat rate for everything under 3oz, so just round up if so
    return {:weight_in_oz => total_weight_in_oz, 
            :service_type => service_type, 
            :package_type => package_type, 
            :user_charge => user_charge}
  end
  
  
  def track
     tracking_info = Stamps.track(self.stamps_tx_id)
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
      from_address = build_address(:user => transaction.seller, :full_name => transaction.seller.username)
      to_address   = build_address(:user => transaction.buyer)    
      create_stamp(:from          => from_address, 
                   :to            => to_address, 
                   :stamps_tx_id  => transaction.transaction_number,
                   :insurance     => false,
                   :insured_value => '0')               
    end
    #TODO: Code insurance algorithm    
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
    details = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters(:card_count => transaction.item_count)
    stamp = Stamps.create!({
               :sample          => STAMPS_CONFIG[:mode] == "production" ? false : true,  # all labels are test labels if we aren't in production mode....
               :image_type      => "Pdf",
               :customer_id     => "12345", #TODO: code customer ID
               :transaction_id  => options[:stamps_tx_id],
               :to              => options[:to],
               :from            => options[:from],
               :memo            => options[:memo] || "MTGBazaar.com",
               :rate            => {
                 :from_zip_code => options[:from][:zip_code],
                 :to_zip_code   => options[:to][:zip_code],
                 :weight_oz     => details[:weight_in_oz],
                 :ship_date     => (Date.today).strftime('%Y-%m-%d'),
                 :package_type  => details[:package_type],
                 :service_type  => details[:service_type],
                 :add_ons       => {
                   :add_on => [
                     { :type => 'SC-A-HP' }, # Hidden Postage
                     { :type => 'US-A-DC' }  # Delivery Confirmation
                   ]
                 }
               }
            })
    self.params = stamp
    self.stamps_tx_id = stamp[:stamps_tx_id]
    self.price = stamp[:rate][:amount]
    buy_postage_if_necessary(:current_balance => stamp[:postage_balance][:available_postage].to_i, 
                             :control_total   => stamp[:postage_balance][:control_total].to_i)
  end
  
  # buy postage if balance is below minimum (only works in STAMPS_CONFIG[:mode] = production)
  def buy_postage_if_necessary(options = {:current_balance => 9999, :control_total => 0})
    min_postage_balance     = 20  # buy postage if balance is under this amount
    max_control_total       = 300 # max amount to spend per month?
    postage_purchase_amount = 30  # amount to purchase at a time
    if STAMPS_CONFIG[:mode] == "production"
      if options[:current_balance] < min_postage_balance && options[:control_total] < max_control_total
          Rails.logger.info("STAMPS: Postage below #{min_postage_balance}, attempting to purchase #{postage_purchase_amount} in postage")
          response = Stamps.purchase_postage(:amount => postage_purchase_amount,
                                             :control_total => options[:control_total])
          if response[:purchase_status] == "Rejected"
            Rails.logger.info("STAMPS: Postage purchase FAILED!, Rejection reason: #{response[:rejection_reason]}")
          else
            Rails.logger.info("STAMPS: Postage purchase SUCCESS!")          
          end
      else
        Rails.logger.info("STAMPS: Checking Postage Balance: #{options[:current_balance]}")          
      end
    else
       Rails.logger.info("STAMPS: We don't buy postage in test mode")          
    end
  end

end