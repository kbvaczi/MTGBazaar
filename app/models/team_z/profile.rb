class TeamZ::Profile < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'team_z_profiles'    
  
  has_one    :user,    :class_name => "User",           :foreign_key => "team_z_profile_id"
  has_one    :article, :class_name => "TeamZ::Article", :foreign_key => "team_z_profile_id"  

  mount_uploader :avatar,  TeamZProfileAvatarUploader
  mount_uploader :picture, TeamZProfilePictureUploader  
  
  # ----- Validations ----- #

  validates_presence_of :display_name, :avatar, :article_series_name, :description

  # ----- Callbacks ----- #    


  # ----- Scopes ------ #
  
  def self.viewable
    where("team_z_profiles.active" => true, "team_z_profiles.approved" => true, "team_z_profiles.active_at" => (1.years.ago..Time.now))
  end

  # ----- Class Methods ----- #
  
end