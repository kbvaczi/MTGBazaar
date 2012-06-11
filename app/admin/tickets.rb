# encoding: UTF-8
ActiveAdmin.register Ticket do

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  #config.clear_action_items! #clear standard buttons
   
  # ------ SCOPES ------- #
  begin
    scope :all, :default => true do |tickets|
      tickets
    end  
    scope :new do |tickets|
      tickets.where(:status => "new")
    end
    scope "Under Review" do |tickets|
      tickets.where(:status => "under review")
    end    
    scope :complete do |tickets|
      tickets.where(:status => "complete")
    end    
  end   
  
  # ------ INDEX ------- #
  # Customize columns displayed on the index screen in the table   
  begin
    index do
      column :number, :sortable => :ticket_number do |ticket|
        link_to ticket.ticket_number, admin_ticket_path(ticket)
      end
      column :status
      column :author, :sortable => false 
      column :problem
      column :offender, :sortable => false 
      column :updates,  :sortable => false do |ticket|
        ticket.updates.count
      end
      column :strike
      column :created_at
      column :updated_at
    end
  end
  
  # ------ FILTERS FOR INDEX ------- #
  filter :author, :as => :select, :collection => proc { User.all }, :input_html => {:class => "chzn-select"}    
  filter :offender, :as => :select, :input_html => {:class => "chzn-select"}      
  filter :status, :as => :select, :collection => ["new","under review","complete"], :input_html => {:class => "chzn-select"}      
  filter :problem, :as => :select, :input_html => {:class => "chzn-select"}      
  filter :strike, :as => :select, :collection => ["",false,true], :input_html => {:class => "chzn-select"}    
  filter :created_at
  filter :updated_at

  # ------ FORM FOR CREATING NEW TICKET ------- #  
  form do |f|
    f.inputs "Details" do
      f.input :author, :as => :select, :collection => User.pluck(:username), :hint => "Select an author to write a ticket on behalf of a user", :input_html => {:class => "chzn-select"}
      f.input :problem, :as => :select, :collection => MTGBazaar::Application::TICKET_PROBLEM_OPTIONS, :input_html => {:class => "chzn-select"}
      f.input :offender, :as => :select, :hint => "only fill this out if ticket pertains to a specific user and not a transaction", :input_html => {:class => "chzn-select"}
      f.input :strike, :label => "Mark a strike against this user?", :as => :boolean
      f.input :description
      f.input :status, :as => :radio, :collection => ["new","under review","complete"]
    end
    f.buttons
  end
  
  controller do
    # This code is evaluated within the controller class
    def create
      @ticket = Ticket.new()
      if (params[:ticket] and params[:ticket][:author_id].present?)
        @ticket.author = User.where(:username => params[:ticket][:author_id]).first 
      else
        @ticket.author = current_admin_user
        AdminUser.current_admin_user = current_admin_user
      end
      @ticket.problem = params[:ticket][:problem]
      if (params[:ticket] and params[:ticket][:offender_id].present?)
        @ticket.offender_username = User.find(params[:ticket][:offender_id]).username
        @ticket.offender_id = params[:ticket][:offender_id]
      end
      @ticket.strike = params[:ticket][:strike]
      @ticket.description = params[:ticket][:description]
      @ticket.status = params[:ticket][:status]
      if @ticket.save
        redirect_to admin_tickets_path
      else
        flash[:error] = "there were problems with your request: #{@ticket.errors.full_messages}"
        render "new"
      end
    end

    def update
      @ticket = Ticket.find(params[:id])
      if (params[:ticket] and params[:ticket][:author_id].present?)
        @ticket.author = User.where(:username => params[:ticket][:author_id]).first 
      else
        @ticket.author = current_admin_user
        AdminUser.current_admin_user = current_admin_user
      end
      @ticket.problem = params[:ticket][:problem]
      if (params[:ticket] and params[:ticket][:offender_id].present?)
        @ticket.offender_username = User.find(params[:ticket][:offender_id]).username
        @ticket.offender_id = params[:ticket][:offender_id]
      end
      @ticket.strike = params[:ticket][:strike]
      @ticket.description = params[:ticket][:description]
      @ticket.status = params[:ticket][:status]
      if @ticket.save
        redirect_to admin_tickets_path
      else
        flash[:error] = "there were problems with your request: #{@ticket.errors.full_messages}"
        render "edit"
      end
    end
  end
      
end
