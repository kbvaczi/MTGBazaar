class CreateNewsFeeds < ActiveRecord::Migration
  def up
    create_table :news_feeds do |t|
      t.integer   :author_id

      t.string    :title,           :default => ""
      t.text      :data
      t.integer   :priority,        :default => "10"
      
      t.timestamps
    end
  end
  
  def down
    drop_table :news_feeds
  end
end
