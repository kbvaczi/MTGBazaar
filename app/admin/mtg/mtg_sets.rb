ActiveAdmin.register Mtg::Set do
  menu :label => "2 - Sets", :parent => "MTG"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  begin
    config.clear_action_items! #clear standard buttons
    action_item :only => :show do
      link_to 'Edit Set', edit_admin_mtg_set_path(mtg_set)
    end    
    action_item :only => :show do
      link_to 'Delete Set', delete_set_admin_mtg_set_path(mtg_set), :confirm => "Warning! Deleting this set will also delete the #{Mtg::Set.find(params[:id]).cards.count} cards that belong to this set.  Are you sure you want to do this?" if !mtg_set.active?
    end
    action_item :only => :show do
      link_to 'Activate all Cards', activate_all_cards_admin_mtg_set_path(mtg_set), :confirm => "Are you sure you want to activate all cards?"
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
    column :id, :sortable => false do |set|
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
    
    column 'Active', :sortable => :active  do |set|
      if set.active?
        status_tag "Yes", :ok
      else
        status_tag "No", :error
      end
    end
  end
  
  # ------ FILTERS FOR INDEX ------- #
  begin   
    filter :name
    filter :code
    filter :block, :as => :select, :input_html => {:class => "chzn-select"}  
    filter :release_date
    filter :updated_at
    filter :created_at
    filter :active
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
  member_action :activate_all_cards do
    set = Mtg::Set.find(params[:id])
    set.cards.each { |c| c.update_attribute(:active, true) if c.active == false }
    respond_to do |format|
      format.html { redirect_to admin_mtg_sets_path, :notice => "All Cards Activated..."}
    end
  end  

end