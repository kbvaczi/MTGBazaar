class NewsFeed < ActiveRecord::Base

  belongs_to  :author,    :class_name => "AdminUser",   :foreign_key => "author_id"
  
  validates_presence_of :data
  
end
