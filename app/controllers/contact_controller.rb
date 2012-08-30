class ContactController < ApplicationController
  
  # breadcrumb navigation
  # add_breadcrumb "Home", :root_path

  def index
    
    @reason = params[:reason] ||= "kudos"
    
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
      redirect_to root_path, :notice => "Thanks for the feedback! Your comments were sent."
    else
      render 'show'
    end
  end
  
end
