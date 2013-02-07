class NewsFeed < ActiveRecord::Base

  belongs_to  :author,    :class_name => "AdminUser",   :foreign_key => "author_id"
  
  validates_presence_of :data, :title, :description
  
  def to_param
    "#{id}-#{title}".parameterize
  end
    
  def self.viewable
    NewsFeed.where("active LIKE ?", true)
            .where("start_at < \'#{Time.zone.now}\' OR start_at IS null")
            .where("end_at > \'#{Time.zone.now}\' OR end_at IS null")    
  end
  

end
