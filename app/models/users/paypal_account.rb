class PaypalAccount
  include ActiveModel::Validations

  validates_presence_of     :first_name, :last_name, :email
  
  validate :validate_verified_account
  validate :validate_confirmed_email
                    
  # to deal with form, you must have an id attribute
  attr_accessor :id, :first_name, :last_name, :email

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
    @attributes = attributes
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end

  def to_key; end

  def save
    if self.valid?
      #self.username = User.find(session["warden.user.user.key"][1]).first rescue nil
      ContactMailer.send_mail(self).deliver
      return true
    end
    return false
  end
  
  def validate_verified_account
    #include the gems needed
    require 'httpclient'
    require 'xmlsimple'

    #set the header of the request
    header =  {"X-PAYPAL-SECURITY-USERID"       => PAYPAL_CONFIG[:api_login],
               "X-PAYPAL-SECURITY-PASSWORD"     => PAYPAL_CONFIG[:api_password],
               "X-PAYPAL-SECURITY-SIGNATURE"    => PAYPAL_CONFIG[:api_signature],
               "X-PAYPAL-REQUEST-DATA-FORMAT"   => "NV",
               "X-PAYPAL-RESPONSE-DATA-FORMAT"  => "XML",
               "X-PAYPAL-APPLICATION-ID"        => PAYPAL_CONFIG[:appid] }
    #data to be sent in the request
    data = {"emailAddress"                  => self.email,
           "firstName"                      => PAYPAL_CONFIG[:running_mode] == "production" ? self.first_name.downcase : "christopher",
           "lastName"                       => PAYPAL_CONFIG[:running_mode] == "production" ? self.last_name.downcase : "odorizzi",
           "matchCriteria"                  => "NAME",
           "requestEnvelope.errorLanguage"  => "en_US"}
    clnt = HTTPClient.new
   # uri = "https://svcs.sandbox.paypal.com/AdaptiveAccounts/GetVerifiedStatus"
    uri = (PAYPAL_CONFIG[:running_mode] == "production") ? "https://svcs.paypal.com/AdaptiveAccounts/GetVerifiedStatus" : "https://svcs.sandbox.paypal.com/AdaptiveAccounts/GetVerifiedStatus"
    #make the post
    res = clnt.post(uri, data, header)
    #if the request is successfull parse the XML
    if res.status == 200
      @xml = XmlSimple.xml_in(res.content)
      #check if the status node exists in the xml
      if @xml['accountStatus']!=nil
        account_status = @xml['accountStatus'][0]
        if account_status.to_s() == "VERIFIED"
          paypal_verify_response = "verified"
        else
          paypal_verify_response = "unverified"
          self.errors[:base] << 'Your PayPal account is not verified...'
        end
      else
        paypal_verify_response = "error"
        self.errors[:base] << 'Error. Please ensure first name, last name, and PayPal email are correct...'
      end
    end
  end
  
  def validate_confirmed_email
    gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(
      :pem =>       PAYPAL_CONFIG[:paypal_cert_pem],
      :login =>     PAYPAL_CONFIG[:api_login],
      :password =>  PAYPAL_CONFIG[:api_password],
      :signature => PAYPAL_CONFIG[:api_signature],
      :appid =>     PAYPAL_CONFIG[:appid] )
      
    recipients = [ {:email        => self.email,
                    :payment_type => "GOODS",
                    :primary      => true,
                    :amount       => 1.00 },
                   {:email        => PAYPAL_CONFIG[:account_email],                                        
                    :payment_type => "SERVICE",
                    :primary      => false,                                                
                    :amount       => 0.50 } ]  
      
    purchase = gateway.setup_purchase(:action_type          => "CREATE",
                                      :return_url           => 'http://www.mtgbazaar.com',  #fake url
                                      :cancel_url           => 'http://www.mtgbazaar.com/cancel', #fake url
                                      :memo                 => "Test purchase to validate user's account is setup properly (confirmed email, etc...)",
                                      :receiver_list        => recipients,
                                      :fees_payer           => "PRIMARYRECEIVER")
                                
    if purchase.error.present?
      if purchase.error[0].include?("isn\'t confirmed by PayPal")
        self.errors[:base] << "Please confirm your email with PayPal prior to continuing..."
      else
        self.errors[:base] << "Error confirming your account credentials..."
      end
    end
  end
  
end