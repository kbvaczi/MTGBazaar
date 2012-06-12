# encoding: UTF-8
ActiveAdmin.register Ticket do

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  #config.clear_action_items! #clear standard buttons
   
  # ------ SCOPES ------- #
  begin
    scope :all do |tickets|
      tickets
    end  
    scope :new, :default => true do |tickets|
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
      column :status, :sortable => :status do |ticket|
        status_tag "Complete", :ok if ticket.status == "complete"
        status_tag "Under Review", :warning if ticket.status == "under review"
        status_tag "New!", :error if ticket.status == "new"
      end
      column :author, :sortable => false 
      column :problem
      column :offender, :sortable => false 
      column :updates,  :sortable => false do |ticket|
        ticket.updates.count
      end
      column :strike, :sortable => :strike do |ticket|
        "true" if ticket.strike
      end
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

  ##### ----- Custom Show Screen ----- #####
  show :title => "Ticket Details" do |ticket|
    h2 "Ticket #{ticket.ticket_number}"
    attributes_table do
      row :author
      row :problem
      row :offender
      row :strike
      row :transaction do 
        link_to ticket.transaction.transaction_number, admin_mtg_transaction_path(ticket.transaction)
      end
      row :description
      row :status do
        if ticket.status == "complete" 
          status_tag "Complete", :ok 
        elsif ticket.status == "under review"
          status_tag "Under Review", :warning
        else
          status_tag "New!", :error if ticket.status == "new"
        end
      end
      row :created_at
      row :updated_at
    end
    panel "Updates (#{ticket.updates.count})" do
      ticket.updates.each do |update| # List all the existing updates
        attributes_table_for update do
          row :author
          row :created_at
          row :description
          row :complete_ticket do 
            "This update closes the ticket" 
          end if update.complete_ticket 
          row :strike do 
            "This update indicates a strike will be applied to the offender"             
          end if update.strike
        end
      end # existing updates
      panel "New Update" do
        render :partial => "admin/tickets/form_update"
      end
    end

    
    active_admin_comments
  end

  # ------ FORM FOR CREATING/EDITING TICKETS ------- #  
  form do |f|
    f.inputs "Details" do
      if ticket.author.class.name != "AdminUser"
        f.input :author,  :as => :select, 
                          :collection => User.all.collect {|u| [u.username, u.id]},
                          :hint => "Select an author to write a ticket on behalf of a user",
                          :input_html => {:class => "chzn-select", :style => "min-width:250px;"}
      else
        f.input :author,  :as => :select, 
                          :collection => AdminUser.all.collect {|u| [u.email, u.id]},
                          :hint => "An admin created this ticket",
                          :input_html => {:class => "chzn-select", :style => "min-width:250px;"}
        
      end
      f.input :status,  :as => :radio, 
                        :collection => ["new","under review","complete"]
      f.input :problem, :as => :select, 
                        :collection => MTGBazaar::Application::TICKET_PROBLEM_OPTIONS, 
                        :input_html => {:class => "chzn-select", :style => "min-width:250px;"}
      f.input :offender,:as => :select, 
                        :hint => "only fill this out if ticket pertains to a specific user and not a transaction", 
                        :input_html => {:class => "chzn-select", :style => "min-width:250px;"}
      f.input :strike,  :label => "Mark a strike against this user?", 
                        :as => :boolean
      f.input :transaction_number, :as => :string,
                                   :value => (ticket.transaction.transaction_number rescue "")
      f.input :description, :input_html => {:rows => 5, :cols => 20, :maxlength => 500}
    end
    f.buttons
  end
  
  # ----- NEW MEMBER ACTIONS ----- # 
  member_action :add_update, :method => :post do
    @ticket = Ticket.find(params[:id])
    @update = TicketUpdate.new
    @update.ticket = @ticket
    @update.author = current_admin_user
    AdminUser.current_admin_user = current_admin_user #set AdminUser.current_admin_user so model can see it
    @update.description = params[:ticket_update][:description]
    @update.complete_ticket = params[:ticket_update][:complete_ticket]
    @update.strike = params[:ticket_update][:strike]
    if @update.save
      flash[:notice] = "Update Created"
      redirect_to admin_ticket_path(@ticket)
    else
      flash[:error] = "There were errors trying to add ticket update #{@update.errors.full_messages}"
      redirect_to admin_ticket_path(@ticket)
    end
  end
  
  # ----- OVERRIDE CONTROLLER METHODS ----- #
  controller do
    # admin create ticket
    def create
      @ticket = Ticket.new()
      if (params[:ticket] and params[:ticket][:author_id].present?)
        @ticket.author = User.find(params[:ticket][:author_id])
      else
        @ticket.author = current_admin_user
        AdminUser.current_admin_user = current_admin_user
      end
      @ticket.problem = params[:ticket][:problem]
      if (params[:ticket] and params[:ticket][:offender_id].present?)
        @ticket.offender_username = User.find(params[:ticket][:offender_id]).username
        @ticket.offender_id = params[:ticket][:offender_id]
      end
      if (params[:ticket] and params[:ticket][:transaction_number].present?)
        @ticket.transaction_number = params[:ticket][:transaction_number]
        @ticket.transaction = Mtg::Transaction.where("transaction_number LIKE ?", params[:ticket][:transaction_number]).first
      end
      @ticket.strike = params[:ticket][:strike]
      @ticket.description = params[:ticket][:description]
      @ticket.status = params[:ticket][:status]
      AdminUser.current_admin_user = current_admin_user #set AdminUser.current_admin_user so model can see it
      if @ticket.save
        redirect_to admin_tickets_path
      else
        flash[:error] = "there were problems with your request: #{@ticket.errors.full_messages}"
        render "new"
      end
    end
    
    # admin update ticket
    def update
      @ticket = Ticket.find(params[:id])
      if (params[:ticket] and params[:ticket][:author_id].present?)
        @ticket.author = User.find(params[:ticket][:author_id]) if @ticket.author.class.name == "User"
        @ticket.author = AdminUser.find(params[:ticket][:author_id]) if @ticket.author.class.name == "AdminUser"
      end
      @ticket.problem = params[:ticket][:problem]
      if (params[:ticket] and params[:ticket][:offender_id].present?)
        @ticket.offender_username = User.find(params[:ticket][:offender_id]).username
        @ticket.offender_id = params[:ticket][:offender_id]
      end
      @ticket.strike = params[:ticket][:strike]
      @ticket.description = params[:ticket][:description]
      @ticket.status = params[:ticket][:status]
      AdminUser.current_admin_user = current_admin_user #set AdminUser.current_admin_user so model can see it      
      if @ticket.save
        redirect_to admin_tickets_path
      else
        flash[:error] = "there were problems with your request: #{@ticket.errors.full_messages}"
        render "edit"
      end
    end
    
  end
      
end
