class ContactController < ApplicationController
  
  def index
    @reason = params[:reason] ||= "Kudos"
    @contact = Contact.new(:id => 1)
  end
  
  def show    
    @contact = Contact.new(params[:contact])
  end

  def create
    @contact = Contact.new(params[:contact].merge!({"ip"=>request.remote_ip, "username" => (User.find(session["warden.user.user.key"][1]).first.username rescue "user not logged in")})) #add IP address
    if @contact.save
      redirect_to root_path, :notice => "Thanks for contacting us! Your message was sent."
    else
      render 'show'
    end
  end
  
end
