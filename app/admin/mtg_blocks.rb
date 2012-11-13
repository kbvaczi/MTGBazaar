ActiveAdmin.register Mtg::Block do
  menu :label => "1 - Blocks", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend Mtg::CardsHelper


  # ------ ACTION ITEMS (BUTTONS) ------- #  
  begin
    config.clear_action_items! #clear standard buttons
    action_item :only => :show do
      link_to 'Edit Block', edit_admin_mtg_block_path(mtg_block)
    end    
    action_item :only => :show do
      link_to 'Delete Block', delete_block_admin_mtg_block_path(mtg_block), :confirm => "Are you sure you want to delete this block, along with #{Mtg::Block.find(params[:id]).sets.count} sets and #{Mtg::Card.joins(:block).count(:conditions => "mtg_blocks.name LIKE \'#{Mtg::Block.find(params[:id]).name}\'")} cards?"
    end
    action_item :only => :index do
      link_to 'Create New Block', new_admin_mtg_block_path
    end
    action_item :only => :index do
      link_to 'Import XML File', upload_xml_admin_mtg_cards_path
    end
  end

  scope :all, :default => true do |blocks|
    blocks.includes(:sets)
  end
  scope :active do |blocks|
    blocks.includes(:sets).where(:active => true)
  end
  scope :inactive do |blocks|
    blocks.includes(:sets).where(:active => false)
  end  
  
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |block|
      link_to block.id, admin_mtg_block_path(block)
    end
    column :name
    column "Sets", :sortable => false do |block|
       link_to block.sets.count, admin_mtg_sets_path("q[block_id_eq]" => block.id)
    end
    column "Cards", :sortable => false do |block|
       link_to block.cards.count, admin_mtg_cards_path("q[block_id_eq]" => block.id)
    end
    column :created_at
    column :updated_at    
    column 'Active?', :sortable => :active  do |block|
      if block.active?
        status_tag "Yes", :ok
      else
        status_tag "No", :error
      end
    end
  end
  
  # ------ CONTROLLER ACTIONS ------- #
   # note: collection_actions work on collections, member_acations work on individual  
    member_action :delete_block do
      @block = Mtg::Block.find(params[:id])
      @block.sets.each do |s|
        s.cards.each {|c| c.destroy}
        s.destroy
      end
      @block.destroy      
      respond_to do |format|
        format.html { redirect_to admin_mtg_blocks_path, :notice => "Block Deleted..."}
      end
    end

end
