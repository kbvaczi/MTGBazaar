class AddArticles < ActiveRecord::Migration
  def up
    
    unless column_exists? :users, :team_z_profile_id
      add_column :users, :team_z_profile_id, :integer
    end
    
    unless table_exists? :team_z_profiles
      create_table  :team_z_profiles do |t|
        #foreign keys      

        #table data
        t.text      :privileges
        t.string    :display_name
        t.string    :avatar
        t.text      :article_series_names
        t.text      :description
        t.timestamps      
      end
    end
    
    unless table_exists? :team_z_articles
      create_table  :team_z_articles do |t|
        #foreign keys      
        t.integer   :team_z_profile_id
        #table data
        t.string    :series_name
        t.string    :title
        t.string    :summary
        t.text      :body   
        t.boolean   :approved
        t.boolean   :active
        t.datetime  :active_at
        t.timestamps
      end
      add_index :team_z_articles, :team_z_profile_id      
      add_index :team_z_articles, :approved
      add_index :team_z_articles, :active    
    end    

  end

  def down
    
    if column_exists? :users, :team_z_profile_id
      remove_column :users, :team_z_profile_id
    end

    drop_table    :team_z_profiles if table_exists? :team_z_profiles
    drop_table    :team_z_articles if table_exists? :team_z_articles    
  end
  
end
