ActiveAdmin.register NewsFeed do
  
  menu :label => "News Feeds"
  
  # ----- CUSTOMIZE EDIT FORM ----- #
  # ----- CUSTOMIZE EDIT FORM ----- #
    
  form :partial => "form"

  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
   # Customize columns displayed on the index screen in the table
   index do
     column :id, :sortable => :id do |news_feed|
       link_to news_feed.id, admin_news_feed_path(news_feed)
     end
     column :title
     column :created_at
     column :updated_at    
   # column :active
   end
  
end

