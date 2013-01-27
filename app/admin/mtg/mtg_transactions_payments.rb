# encoding: UTF-8
ActiveAdmin.register Mtg::Transactions::Payment do

  menu :label => "4 - Payments", :parent => "Transactions"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class
  extend ApplicationHelper
  
  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
   
  # ------ SCOPES ------- #
  begin
    scope :all do |payments|
      payments.includes(:transaction)
    end  
    scope "Unpaid" do |payments|
      payments.includes(:transaction).where(:status => "unpaid")  
    end
    scope "Completed", :default => true do |payments|
      payments.includes(:transaction).where(:status => "completed")
    end
    scope "Refunded" do |payments|
      payments.includes(:transaction).where(:status => "refunded")
    end
  end   

  # ------ INDEX ------- #
  # Customize columns displayed on the index screen in the table   
  index :title => "Payments" do |payment|
    column :id, :sortable => :id do |payment|
      link_to payment.id, admin_mtg_transactions_payment_path(payment)
    end
    column :status, :sortable => :status do |payment|
      case payment.status
        when "unpaid"
          status_tag "Unpaid", :warning
        when "completed"
          status_tag "Completed", :ok
        when "refunded"
          status_tag "Refunded", :error
        else
          "error"
      end
    end
    column :amount, :sortable => :amount do |payment|
      number_to_currency payment.amount
    end
    column :commission_rate, :sortable => :commission_rate do |payment|
      (payment.commission_rate * 100).to_s + "%"
    end
    column :commission do |payment|
      number_to_currency payment.commission
    end    
    column :shipping_cost do |payment|
      number_to_currency payment.shipping_cost
    end    
    column "Buyer", :sortable => false do |payment|
      payment.transaction.buyer.username rescue ""
    end
    column "Seller", :sortable => false do |payment|
      payment.transaction.seller.username rescue ""
    end
    column "Notifications", :sortable => false do |payment|
      payment.payment_notifications.count
    end
    column :transaction, :sortable => false do |payment|
      link_to payment.transaction.transaction_number, admin_mtg_transactions_path("q[transaction_number_eq]" => payment.transaction.transaction_number)
    end    
    column :created_at
    #column :updated_at
  end
  
  ##### ----- Custom Show Screen ----- #####
    show :title => "Payment Information" do |payment|
      columns do
        column do       
          attributes_table do
            row :id
            row :status do
              case payment.status
               when "unpaid"
                 status_tag "Unpaid", :warning
               when "completed"
                 status_tag "Completed", :ok
               when "refunded"
                 status_tag "Refunded", :error
               else
                 "error"
              end
            end
            row :amount do 
              number_to_currency payment.amount
            end
            row "User's Shipping Cost" do
              number_to_currency payment.shipping_cost
            end
            row :commission do 
              number_to_currency payment.commission
            end
            row :commission_rate do 
              (payment.commission_rate * 100).to_s + "%"
            end            
            row :paypal_paykey
            row :paypal_transaction_number

            row :transaction do
             link_to payment.transaction.transaction_number, admin_mtg_transactions_path("q[transaction_number_eq]" => payment.transaction.transaction_number)
            end
            row :paypal_transaction_number
          end
        end
        column do

          panel "Payment Notifications" do
            div do
              payment.payment_notifications.each do |notification|
                div do
                  text_node notification.inspect rescue ""
                end
              end
            end
          end
        end  
      end
      panel "Raw Purchase Response" do
        payment.paypal_purchase_response
      end
      active_admin_comments      
    end 

end