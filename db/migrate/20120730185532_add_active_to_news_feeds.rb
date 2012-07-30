class AddActiveToNewsFeeds < ActiveRecord::Migration
  def up
    add_column :news_feeds, :start_at, :datetime
    add_column :news_feeds, :end_at, :datetime
    add_column :news_feeds, :active, :boolean, :default => true
  end
  
  def down
    remove_column :news_feeds, :start_at
    remove_column :news_feeds, :end_at  
    remove_column :news_feeds, :active        
  end
end
