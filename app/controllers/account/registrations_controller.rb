class Account::RegistrationsController < Devise::RegistrationsController

  def new
    @user = resource
    super
  end
  
  def edit
    @user = resource
    super      
  end
  
  def update
    set_address_info
    set_paypal_verification_status
    super
  end
  
  def create
    set_address_info
    set_paypal_verification_status
    super
  end
  
  def verify_paypal
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
    data = {"emailAddress"                  => params[:email],
           "firstName"                      => Rails.env.production? ? params[:first_name].downcase : "christopher",
           "lastName"                       => Rails.env.production? ? params[:last_name].downcase : "odorizzi",
           "matchCriteria"                  => "NAME",
           "requestEnvelope.errorLanguage"  => "en_US"}
    clnt = HTTPClient.new
   # uri = "https://svcs.sandbox.paypal.com/AdaptiveAccounts/GetVerifiedStatus"
    uri = (Rails.env.production? && PAYPAL_CONFIG[:mode] == "production") ? "https://svcs.paypal.com/AdaptiveAccounts/GetVerifiedStatus" : "https://svcs.sandbox.paypal.com/AdaptiveAccounts/GetVerifiedStatus"
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
        end
      else
        paypal_verify_response = "error"
      end
    end
    
  
    respond_to do |format|
      format.json do         
        case paypal_verify_response
          when "verified"
            session[:paypal_verify_response] = true
          else
            session[:paypal_verify_response] = false
        end
        render :json => paypal_verify_response.to_json
      end
    end
  
  end
  
  def verify_address
    address = {
      :first_name  => params[:first_name],
      :last_name   => params[:last_name],
      :address1    => params[:address1],
      :address2    => params[:address2],              
      :city        => params[:city],
      :state       => params[:state],
      :zip_code    => params[:zip_code]
    }
    
    begin
      @response = Stamps.clean_address(:address => address)
      session[:address_info] = @response[:address]
    rescue Exception
      @error = true 
    end 
        
    respond_to do |format|
      format.js { }
    end
  end
  
  def set_address_info
    if session[:address_info]
      address_info = session[:address_info]
      params[:user][:account_attributes][:address1] = address_info[:address1] || ""
      params[:user][:account_attributes][:address2] = address_info[:address2] || ""          
      params[:user][:account_attributes][:city] = address_info[:city] || ""             
      params[:user][:account_attributes][:state] = address_info[:state] || ""
      params[:user][:account_attributes][:zipcode] = address_info[:zip_code] || ""
      params[:user][:account_attributes][:address_verification] = { :cleanse_hash => address_info[:cleanse_hash], :override_hash => address_info[:override_hash] } || ""
      session[:address_info] = nil
    end
  end
  
  def set_paypal_verification_status
    params[:user][:account_attributes][:paypal_verified] = false if session[:paypal_verify_response] == false || session[:paypal_verify_response] == "false"
  end
  
  # devise redirect after sign up
  def after_inactive_sign_up_path_for(resource)
    if resource.is_a?(User)
      resource.statistics.update_ip_log(resource.current_sign_in_ip) # update IP Log
      welcome_path
    else
      super
    end
  end    
  
  def after_update_path_for(resource)
    case resource
    when :user, User  
      if resource.updated_at > 10.seconds.ago || resource.account.updated_at > 10.seconds.ago #account_before_update != account_after_update || user_before_update != user_after_update
        ApplicationMailer.account_update_notification(resource).deliver
      end
      account_info_path
    else
      super
    end
  end
  
end
