class TicketsController < ApplicationController
  
  before_filter :authenticate_user!   # user must be logged in prior to accessing any of these views
  
  # form for user to create a new ticket
  def new
    @ticket = Ticket.new(params[:ticket])
  end

  # ticket is created based on submitted information
  def create 
    @ticket = Ticket.new(params[:ticket])
    if admin_user_signed_in?
      @ticket.author = current_admin_user # set author as current admin if logged in...
    else
      @ticket.author = current_user # if no admin is logged in, set to current user...
    end
    User.current_user = current_user # set current User.current_user to be used in model validations
    AdminUser.current_admin_user = current_admin_user # set current admin user
    if @ticket.save
      redirect_to tickets_path, :notice => "Your ticket was created and will be reviewed shortly"
    else
      flash[:error] = "There were one or more problems with your request"
      render "new"
    end
  end
  
  # list tickets authored by current logged in user
  def index
    if params[:status].present?
      @tickets = Ticket.where(:author_id => current_user.id, :status => params[:status]).order("created_at DESC").page(params[:page]).per(20) # gather current user's tickets and order them chronologically
    else
      @tickets = Ticket.where(:author_id => current_user.id).order("created_at DESC").page(params[:page]).per(20) 
    end
  end
  
  # show details for a specific ticket authored by current logged in user
  def show
    
  end
  
end