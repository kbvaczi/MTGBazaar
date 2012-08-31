class AddTeaserToNewsFeeds < ActiveRecord::Migration
  def up
    add_column :news_feeds, :description, :string
  end
  
  def down
    remove_column :news_feeds, :description      
  end
end