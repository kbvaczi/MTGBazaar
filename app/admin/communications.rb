ActiveAdmin.register Communication do

  menu :label => "Communications"
  
  # ------ INDEX ------- #
  index do
    column :id
    column :sender
    column :receiver
    column :message do |comm|
      comm.message.truncate(30, :omission => "...")
    end
    column "Sent", :sortable => :created_at do |comm|
      display_time comm.created_at
    end
    column "Read", :sortable => false do |comm|
      if comm.unread
        nil
      else
        display_time comm.updated_at
      end
    end
    column "Actions" do |comm|
      "#{link_to 'View', admin_communication_path(comm)} | #{link_to 'Edit', edit_admin_communication_path(comm)} | #{link_to 'Delete', admin_communication_path(comm), :method => :delete, :confirm => "Are you sure you want to delete this message?"}".html_safe
    end
  end

  # ------ FILTERS FOR INDEX ------- #
  filter :sender,             :as => :select, :collection => User.select([:id, :username]), :input_html => {:class => "chzn-select"}
  filter :sender_type_equals, :as => :hidden, :input_html => {:value => "User"}, :wrapper_html => {:style => "list-style:none;"}
  filter :receiver,           :as => :select, :collection => User.select([:id, :username]), :input_html => {:class => "chzn-select"}
  #filter :unread,             :as => :check_boxes
  filter :created_at
  filter :updated_at

  # ------ FORM --------------------- #
  
  form do |f|
    f.inputs "Details" do
      if f.object.new_record?
        f.input :sender_id,     :as => :hidden,
                                :value => current_admin_user.id   
        f.input :sender_type,   :as => :hidden,
                                :value => "AdminUser"
      else
        f.input :sender,        :collection => [f.object.sender],
                                :input_html => {:class => "chzn-select", :style => "width:200px;"},
                                :disabled => "disabled", 
                                :required => true
      end

      f.input :receiver,      :collection => User.select([:id, :username]),
                              :input_html => {:class => "chzn-select", :style => "width:200px;"},
                              :required => true
      f.input :message,       :as => :text,
                              :required => true,
                              :hint => "500 Characters Max",
                              :input_html => {:maxlength => "500"}                            
                              
      f.input :unread
    end
    f.buttons
  end

end
