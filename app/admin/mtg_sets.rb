ActiveAdmin.register Mtg::Set do
  menu :label => "Sets", :parent => "MTG"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  begin
    config.clear_action_items! #clear standard buttons
    action_item :only => :show do
      link_to 'Edit Set', edit_admin_mtg_set_path(mtg_set)
    end    
    action_item :only => :show do
      link_to 'Delete Set', delete_set_admin_mtg_set_path(mtg_set), :confirm => "Warning! Deleting this set will also delete the #{Mtg::Set.find(params[:id]).cards.count} cards that belong to this set.  Are you sure you want to do this?"
    end
    action_item :only => :index do
      link_to 'Create New Set', new_admin_mtg_set_path
    end
    action_item :only => :index do
      link_to 'Import XML File', upload_xml_admin_mtg_cards_path
    end    
  end
  
  # ------ SCOPES (auto sorts)------ #
  scope :all, :default => true

  scope :active do |sets|
    sets.where(:active => true)
  end
  scope :inactive do |sets|
    sets.where(:active => false)
  end  
  
  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |set|
      link_to set.id, admin_mtg_set_path(set)
    end
    column :name
    column :code
    column "Symbol", :sortable => false do |set|
      display_set_symbol(set)
    end
    column "Cards", :sortable => false do |set|
       link_to set.cards.count, admin_mtg_cards_path("q[set_id_eq]" => set.id)
    end
    column :release_date
    column :created_at
    column :updated_at    
    column :active
  end

  # ------ CONTROLLER ACTIONS ------- #
  # note: collection_actions work on collections, member_acations work on individual  
   member_action :delete_set do
      @mtg_set = Mtg::Set.find(params[:id])
      @mtg_set.cards.each { |c| c.destroy }
      @mtg_set.destroy
      respond_to do |format|
        format.html { redirect_to admin_mtg_sets_path, :notice => "Set Deleted..."}
      end
    end
    controller do
      before_filter :super_admin_authenticate, :only => :delete_card
      
      def super_admin_authenticate
        authenticate_or_request_with_http_basic "This action requires special access" do |username, password|
          username == "superadmin" && password == "superadmin" 
        end 
      end  
    end
end