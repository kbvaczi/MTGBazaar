class AddArticles < ActiveRecord::Migration
  def up
    
    unless column_exists? :users, :team_z_profile_id
      add_column :users, :team_z_profile_id, :integer
    end
    
    unless table_exists? :team_z_profiles
      create_table  :team_z_profiles do |t|
        #foreign keys      

        #table data
        t.string    :display_name
        t.string    :avatar
        t.string    :picture        
        t.text      :data
        
        t.boolean   :can_write_articles
        t.string    :article_series_name        
        t.boolean   :can_post_videos        
        t.boolean   :can_stream
        t.string    :twitch_tv_username
        t.boolean   :can_manage_content
        
        t.boolean   :active
        t.timestamps      
      end
    end
    
    unless table_exists? :team_z_articles
      create_table  :team_z_articles do |t|
        #foreign keys      
        t.integer   :team_z_profile_id
        #table data
        t.string    :title
        t.string    :description
        t.text      :body
        
        t.string    :status
        t.boolean   :active
        t.datetime  :active_at
        t.timestamps
      end
      add_index :team_z_articles, :team_z_profile_id
      add_index :team_z_articles, :status
      add_index :team_z_articles, :active    
    end  
    
    unless table_exists? :team_z_mtgo_video_series
      create_table  :team_z_mtgo_video_series do |t|
        #foreign keys      
        t.integer   :team_z_profile_id
        #table data
        t.string    :title
        t.string    :description
        t.boolean   :active
        t.datetime  :active_at
        t.timestamps
      end
      add_index :team_z_mtgo_video_series, :team_z_profile_id
      add_index :team_z_mtgo_video_series, :active
    end
    
    unless table_exists? :team_z_mtgo_videos
      create_table  :team_z_mtgo_videos do |t|
        #foreign keys      
        t.integer   :video_series_id
        #table data
        t.string    :title
        t.string    :video_link
        t.string    :video_number        
        t.timestamps
      end
      add_index :team_z_mtgo_videos, :video_series_id
    end    

    unless table_exists? :admin_slider_center_slides
      create_table  :admin_slider_center_slides do |t|   
        #foreign keys      
        t.integer   :news_feed_id
        #table data
        t.string    :title
        t.string    :description
        t.string    :image
        t.string    :link_type,   :default => 'URL'
        t.string    :link
        t.integer   :slide_number
        t.timestamps      
      end
    end

  end

  def down
    
    if column_exists? :users, :team_z_profile_id
      remove_column :users, :team_z_profile_id
    end

    drop_table    :team_z_profiles    if table_exists? :team_z_profiles
    drop_table    :team_z_articles    if table_exists? :team_z_articles
    drop_table    :team_z_mtgo_videos if table_exists? :team_z_mtgo_videos
    drop_table    :team_z_mtgo_video_series   if table_exists? :team_z_mtgo_video_series
    drop_table    :admin_slider_center_slides if table_exists? :admin_slider_center_slides
  end
  
end
