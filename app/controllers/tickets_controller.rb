class TicketsController < ApplicationController
  
  before_filter :authenticate_user!   # user must be logged in prior to accessing any of these views
  
  # form for user to create a new ticket
  def new
    @ticket = Ticket.new(params[:ticket])
  end

  # ticket is created based on submitted information
  def create
    @ticket = Ticket.new(params[:ticket])
    @ticket.status = "open"
    @ticket.author = current_user # if no admin is logged in, set to current user...
    @ticket.current_user = current_user # set current current_user to be used in model validations
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
      if params[:status] == "active"
        @tickets = Ticket.includes(:updates).where(:author_id => current_user.id, :author_type => "User").active.order("created_at DESC").page(params[:page]).per(20) # gather current user's tickets and order them chronologically
      else
        @tickets = Ticket.includes(:updates).where(:author_id => current_user.id, :author_type => "User", :status => "new").order("created_at DESC").page(params[:page]).per(20) # gather current user's tickets and order them chronologically
      end
    else
      @tickets = Ticket.includes(:updates).where(:author_id => current_user.id, :author_type => "User").order("created_at DESC").page(params[:page]).per(20) 
    end
    respond_to do |format|
      format.html
      format.js  { default_js_render :template => 'tickets/index' }
    end
  end
  
  # show details for a specific ticket authored by current logged in user
  def show
    @ticket = Ticket.includes(:updates).where(:author_id => current_user.id, :author_type => "User", :id => params[:id]).first
    @ticket_updates = @ticket.updates.order("created_at DESC")
    @ticket_update = TicketUpdate.new(params[:ticket_update])
    if not @ticket.present?
      flash[:error] = "there was a problem with your request"
      redirect_to tickets_path
    end
  end
  
  def new_update
    @ticket_update = TicketUpdate.new(params[:ticket_update])
  end
  
  def create_update
    @ticket = Ticket.where(:author_id => current_user.id, :author_type => "User", :id => params[:id]).first
    @ticket_update = TicketUpdate.new(params[:ticket_update]) 
    @ticket_update.ticket_id = @ticket.id
    @ticket_update.author = current_user # if no admin is logged in, set to current user...
    @ticket.current_user = current_user # set current_user to be used in model validations...
    if @ticket.status == "closed"
      flash[:error] = "Communication has been closed for this ticket..."
      render "show"     
    elsif @ticket_update.save
      @ticket.update_attribute(:status, "open") if @ticket.status == "resolved"
      redirect_to ticket_path(@ticket), :notice => "Ticket updated..."
    else
      flash[:error] = "There were one or more problems with your request..."
      render "show"
    end
  end
  
end