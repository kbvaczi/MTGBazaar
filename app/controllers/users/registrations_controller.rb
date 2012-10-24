class Users::RegistrationsController < Devise::RegistrationsController

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
    super
    ApplicationMailer.account_update_notification(resource).deliver
  end
  
  def create
    set_address_info
    super
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
  
end
