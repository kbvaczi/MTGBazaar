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
  
end
