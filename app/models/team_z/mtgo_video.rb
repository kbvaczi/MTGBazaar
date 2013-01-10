class TeamZ::MtgoVideo < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'team_z_mtgo_videos'    
  
  belongs_to :video_series, :class_name => "TeamZ::MtgoVideoSeries", :foreign_key => "video_series_id"

  # override default route to add username in route.
  def to_param
    "#{id}-#{self.title}".parameterize
  end

  # ----- Validations ----- #

  validates_presence_of :video_series_id, :title

  # ----- Callbacks ----- #    


  # ----- Scopes ------ #
  
  def self.viewable
    joins(:video_series => :profile).where("team_z_mtgo_video_series.active" => true, 'team_z_profile.active' => true).where("team_z_mtgo_video_series.active_at < ? OR team_z_mtgo_video_series.active_at IS ?", Time.now, nil)
  end

  # ----- Class Methods ----- #
  
  def posted_at
    if self.active_at == nil || self.created_at >= self.active_at 
      self.created_at
    else
      self.active_at
    end
  end
  
end