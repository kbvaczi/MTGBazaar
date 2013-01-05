class NewsFeed < ActiveRecord::Base

  belongs_to  :author,    :class_name => "AdminUser",   :foreign_key => "author_id"
  
  validates_presence_of :data, :teaser_picture, :title, :description
  
  mount_uploader :teaser_picture,  NewsFeedTeaserPictureUploader
    
  def self.available_to_view
    NewsFeed.where("active LIKE ?", true)
            .where("start_at < \'#{Time.now}\' OR start_at IS null")
            .where("end_at > \'#{Time.now}\' OR end_at IS null")    
  end
  

end
