class TeamZ::Profile < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'team_z_profiles'    
  
  has_one    :user,              :class_name => "User",                   :foreign_key => "team_z_profile_id"
  has_many   :articles,          :class_name => "TeamZ::Article",         :foreign_key => "team_z_profile_id"  
  has_many   :mtgo_video_series, :class_name => "TeamZ::MtgoVideoSeries", :foreign_key => "team_z_profile_id"    
  has_many   :mtgo_videos,       :class_name => "TeamZ::MtgoVideo",       :through => :mtgo_video_series,     :foreign_key => "video_series_id"      

  mount_uploader :avatar,  TeamZProfileAvatarUploader
  mount_uploader :picture, TeamZProfilePictureUploader  
  
  # ----- Validations ----- #

  validates_presence_of :display_name, :article_series_name, :description

  # ----- Callbacks ----- #    


  # ----- Scopes ------ #
  
  def self.active
    where("team_z_profiles.active" => true)
  end

  # ----- Class Methods ----- #
  
end