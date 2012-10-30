class ContactController < ApplicationController
  
  # breadcrumb navigation
  # add_breadcrumb "Home", :root_path

  def index
    
    @reason = params[:reason] ||= "Kudos"
    
    @contact = Contact.new(:id => 1)
    
    # breadcrumb navigation
    # add_breadcrumb "Contact", :contact_path
  end
  
  def show    
    @contact = Contact.new(params[:contact])
    # breadcrumb navigation
    # add_breadcrumb "Contact", :contact_path
  end

  def create
    @contact = Contact.new(params[:contact].merge!({"ip"=>request.remote_ip})) #add IP address
    if @contact.save
      redirect_to root_path, :notice => "Thanks for contacting us! Your message was sent."
    else
      render 'show'
    end
  end
  
end
