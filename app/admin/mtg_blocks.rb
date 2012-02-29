ActiveAdmin.register MtgBlock do
  menu :label => "Blocks", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend MtgCardsHelper


  # ------ ACTION ITEMS (BUTTONS) ------- #  
  begin
    config.clear_action_items! #clear standard buttons
    action_item :only => :show do
      link_to 'Edit Block', edit_admin_mtg_block_path(mtg_block)
    end    
    action_item :only => :show do
      link_to 'Delete Block', delete_block_admin_mtg_block_path(mtg_block), :confirm => "Are you sure you want to delete this block, along with #{MtgBlock.find(params[:id]).sets.count} sets and #{MtgCard.joins(:block).count(:conditions => "mtg_blocks.name LIKE \'#{MtgBlock.find(params[:id]).name}\'")} cards?"
    end
    action_item :only => :index do
      link_to 'Create New Block', new_admin_mtg_block_path
    end
  end

  scope :all, :default => true
  scope :active do |blocks|
    blocks.where(:active => true)
  end
  scope :inactive do |blocks|
    blocks.where(:active => false)
  end  
  
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |block|
      link_to block.id, admin_mtg_block_path(block)
    end
    column :name
    column :created_at
    column :updated_at    
    column :active
  end
  
  # ------ CONTROLLER ACTIONS ------- #
   # note: collection_actions work on collections, member_acations work on individual  
    member_action :delete_block do
      @block = MtgBlock.find(params[:id])
      @block.sets.each do |s|
        s.cards.each {|c| c.destroy}
        s.destroy
      end
      @block.destroy      
      respond_to do |format|
        format.html { redirect_to admin_mtg_blocks_path, :notice => "Block Deleted..."}
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
