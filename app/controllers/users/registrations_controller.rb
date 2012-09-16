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
    EmailQueue.push(:template => "account_update_notification", :data => resource)
    super
  end
  
  def create
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
    
    @response = Stamps.clean_address(:address => address)
    @address_verification = {:cleanse_hash => @response[:address][:cleanse_hash], :override_hash => @response[:address][:override_hash]}
    
    respond_to do |format|
      format.js { }
    end
  end
  
  protected

  #pass single or array of keys, which will be removed, returning the remaining hash  
  def remove!(*keys)
    
    self
  end

  #non-destructive version
  def remove(*keys)
    self.dup.remove!(*keys)
  end
  
end
