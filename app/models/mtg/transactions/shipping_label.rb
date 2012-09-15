class Mtg::Transactions::ShippingLabel < ActiveRecord::Base
  self.table_name = 'mtg_transactions_shipping_labels'    
  
  belongs_to :transaction,  :class_name => "Mtg::Transaction",  :foreign_key => "transaction_id"
  serialize :params
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :price, :transaction, :url, :params, :stamps_tx_id
  
  attr_accessor :transaction_number, :postage_absent
  
  # validations
  before_validation :buy_postage_if_none_exists

  validates_presence_of :transaction
  validates_presence_of :price, :url, :params, :stamps_tx_id, :if => "postage_absent"
  validates             :price, :numericality => {:greater_than => 0, :less_than => 5000, :message => "Must be between $0.01 and $50"}, :if => "postage_absent"   #price must be between $0 and $10,000.00  

  def buy_postage_if_none_exists
    t = self.transaction
    if !t.present? || t.shipping_label.present?
      self.errors[:base] << "Shipping label already exists..."
      postage_absent = false
      return
    end
    postage_absent = false
    from_address = build_address(:user => t.seller, :full_name => t.seller.username)
    to_address = build_address(:user => t.buyer, :clean => true)    
    create_stamp(:from           => from_address, 
                 :to             => to_address, 
                 :stamps_tx_id => "1234567890ABCDEFZ",
                 :memo => t.transaction_number,
                 :weight_in_oz   => '2.5')
    #TODO: Code shipping weight algorithm
  end
  
  private
  
  def build_address(params={})
    a = {
      :full_name   => params[:full_name].present? ? params[:full_name] : "#{params[:user].account.first_name} #{params[:user].account.last_name}" ,
      :first_name  => params[:user].account.first_name,
      :last_name   => params[:user].account.last_name,
      :address1    => params[:user].account.address1,
      :address2    => params[:user].account.address2,                  
      :city        => params[:user].account.city,
      :state       => params[:user].account.state,
      :zip_code    => params[:user].account.zipcode
    }
    params[:clean] == true ? Stamps.clean_address(:address => a)[:address] : a
  end
  
  def create_stamp(params={})
    stamp = Stamps.create!({
             :sample          => true,
             :transaction_id  => params[:stamps_tx_id],
             :to              => params[:to],
             :from            => params[:from],
             :memo            => "MTGBazaar.com\r\n" + params[:memo],
             :rate            => {
               :from_zip_code => params[:from][:zip_code],
               :to_zip_code   => params[:to][:zip_code],
               :weight_oz     => params[:weight_in_oz],
               :ship_date     => Date.today.strftime('%Y-%m-%d'),
               :package_type  => 'Package',
               :service_type  => 'US-FC',
               :add_ons       => {
                 :add_on => [
                   { :type => 'SC-A-HP' }, # Hidden Postage
                   { :type => 'US-A-DC' }  # Delivery Confirmation
                 ]
               }
             }
             })
    
    self.params = stamp
    self.stamps_tx_id = stamp[:integrator_tx_id]
    self.price = stamp[:rate][:amount]
    self.url = stamp[:url]
  end
  
end