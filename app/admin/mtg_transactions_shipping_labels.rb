# encoding: UTF-8
ActiveAdmin.register Mtg::Transactions::ShippingLabel do

  extend Mtg::CardsHelper           # access mtg_card helpers inside this class
  extend Mtg::ShippingLabelsHelper
  extend ApplicationHelper

  menu :label => "3 - Shipping Labels", :parent => "Transactions"
  
  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
  action_item :only => :show do
    link_to 'Update Tracking', update_tracking_admin_mtg_transactions_shipping_label_path, :method => :post
  end
  action_item :only => :show do
    link_to 'Refund Shipping', refund_admin_mtg_transactions_shipping_label_path, :method => :post, :confirm => "Are you sure you want to refund shipping? This will break an active transaction. Note: This does not refund seller in PayPal, which must be done manually."
  end  
   
  # ------ SCOPES ------- #
  begin
    scope :all do |labels|
      labels.includes(:transaction)
    end  
    scope "Active", :default => true do |labels|
      labels.includes(:transaction).where(:status => "active")
    end
    scope "Delivered" do |labels|
      labels.includes(:transaction).where(:status => "delivered")
    end
    scope "Refunded" do |labels|
      labels.includes(:transaction).where(:status => "refunded")
    end    
  end   

  # ------ INDEX ------- #
  # Customize columns displayed on the index screen in the table   
  index :title => "Shipping Labels" do
    column :id, :sortable => :id do |label|
      link_to label.id, admin_mtg_transactions_shipping_label_path(label)
    end
    column "Buyer", :sortable => false do |label|
      label.transaction.buyer.username
    end
    column "Seller", :sortable => false do |label|
      label.transaction.seller.username
    end
    column "View", :sortable => false do |label|
      link_to "View", label.params[:url], :target => "_blank"
    end    
    column :status, :sortable => :status do |label|
      case label.status
        when "active"
          status_tag "Active", :warning
        when "shipped"
          statust_tag "Shipped", :ok
        when "refunded"
          status_tag "Refunded", :error
        when "delivered"
          status_tag "Delivered", :ok          
      end
    end
    column :transaction, :sortable => false do |label|
      link_to label.transaction.transaction_number, admin_mtg_transactions_path("q[transaction_number_eq]" => label.transaction.transaction_number)
    end
    column "Last Tracking Event", :sortable => false do |label|
      label.tracking_events.first[:event] if label.tracking_events.present?
    end
    column "Last Tracking Update", :sortable => false do |label|
      label.tracking_events.first[:timestamp] if label.tracking_events.present?
    end
    column "Our Price", :sortable => :price do |label|
      number_to_currency label.price
    end
    column "User Paid", :sortable => "mtg_transactions.shipping_cost" do |label|
      number_to_currency label.transaction.shipping_cost
    end
    column "Weight", :sortable => false do |label|
      label.params[:rate][:weight_oz] + " oz" rescue nil
    end

    
    column :created_at
    #column :updated_at
  end
  
  # ------ FILTERS FOR INDEX ------- #
  
  ##### ----- Custom Show Screen ----- #####
  show :title => "Shipping label Information" do |label|
    columns do
      column do
        attributes_table do
          row :id
          row :status do
            case label.status
              when "active"
                status_tag "Active", :warning
              when "refunded"
                status_tag "Refunded", :error
              when "delivered"
                status_tag "Delivered", :ok          
              else
                label.status
            end
          end
          row "View Stamp" do
            link_to "Click to view stamp", label.params[:url], :target => "_blank"
          end
          row :transaction do
            link_to label.transaction.transaction_number, admin_mtg_transactions_path("q[transaction_number_eq]" => label.transaction.transaction_number)
          end
          row "Add Ons" do
            output_string = ""
            label.params[:rate][:add_ons][:add_on_v2].each do |ao|
              output_string << "#{display_add_on ao[:add_on_type]}</br>"
            end
            output_string.html_safe
          end
          row "Our Price" do
            number_to_currency label.price
          end
          row "User Paid" do
            number_to_currency label.transaction.shipping_cost
          end            
          row "Weight Class" do
            label.params[:rate][:effective_weight_in_ounces] + " oz" rescue nil
          end
        end
        
        panel "Tracking Information" do  
          output_string = "<table>"
          output_string << %{<tr>
                              <th width="30%">Date</th>
                              <th width="25%">Location</th>
                              <th>Event</th>    
                            </tr>}
          label.tracking_events.each do |event| 
            output_string << "<tr>"
            output_string << "<td>#{event[:timestamp].strftime("%m/%d/%y at %I:%M%p CST")}</td>"
            if event[:city]
              output_string << "<td>#{capitalize_first_letters(event[:city])}, #{event[:state]} #{event[:zipcode]}</td>"
            else 
              output_string << "<td>#{event[:zipcode]}</td>"
            end 
            output_string << "<td><p>#{capitalize_first_letters(event[:event])}</p></td>"
            output_string << "</tr>"
          end
          output_string << "</table>"
          text_node output_string.html_safe 
        end
      end
      
      column do
        panel "Raw Response from Stamps" do
          div :style => "word-wrap:break-word;width:100%;" do 
            text_node pretty_print_hash(label.params)
          end
        end
      end
    end
    active_admin_comments
  end

  # --------- Controller Functions ----------- # 
  
  # manually update tracking information for this stamp
  member_action :update_tracking, :method => :post do
    if Mtg::Transactions::ShippingLabel.find(params[:id]).update_tracking
      redirect_to admin_mtg_transactions_shipping_label_path(params[:id]), :notice => "Tracking Information Updated"      
    else 
      flash[:error] = "Error Updating tracking Information"
      redirect_to admin_mtg_transactions_shipping_label_path(params[:id])
    end 
  end
  
  # refund this label
  member_action :refund, :method => :post do
    stamp = Mtg::Transactions::ShippingLabel.find(params[:id])
    if stamp.refund
      redirect_to admin_mtg_transactions_shipping_label_path(params[:id]), :notice => "Requested refund for this stamp... This does not credit seller in paypal..."      
    else 
      flash[:error] = "Error Refunding"
      redirect_to admin_mtg_transactions_shipping_label_path(params[:id])
    end 
  end
  
end