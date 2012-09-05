ActiveAdmin.register SiteVariable do
  # ------ INDEX ------- #
   # Customize columns displayed on the index screen in the table   
    index do
      column :id, :sortable => :id do |v|
        link_to v.id, admin_site_variable_path(v)
      end
      column :name
      column :active
      column :start_at
      column :end_at
      column :created_at
      column :updated_at
    end
end
