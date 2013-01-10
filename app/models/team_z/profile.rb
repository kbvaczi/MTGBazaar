class TeamZ::Profile < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'team_z_profiles'    
  
  has_one    :user,              :class_name => "User",                   :foreign_key => "team_z_profile_id"
  has_many   :articles,          :class_name => "TeamZ::Article",         :foreign_key => "team_z_profile_id"  
  has_many   :mtgo_video_series, :class_name => "TeamZ::MtgoVideoSeries", :foreign_key => "team_z_profile_id"    
  has_many   :mtgo_videos,       :class_name => "TeamZ::MtgoVideo",       :through => :mtgo_video_series,     :foreign_key => "video_series_id"      

  mount_uploader :avatar,  TeamZProfileAvatarUploader
  mount_uploader :picture, TeamZProfilePictureUploader  
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{self.display_name}".parameterize
  end
  
  serialize :data
  
  # ----- Validations ----- #

  validates_presence_of   :display_name, :article_series_name, :data
  validates_uniqueness_of :display_name

  # ----- Callbacks ----- #    


  # ----- Scopes ------ #
  
  def self.active
    where("team_z_profiles.active" => true)
  end

  # ----- Class Methods ----- #
  
  def self.default_profile_fields
    ['Description', 'Age', 'Occupation', 'Twitter Hashtag', 'Magic Online Username', 'Hometown', 'Guild affiliation', 'How long have you played Magic', 
     'How did you learn to play Magic', 'What is your biggest achievement in Magic so far', 'How often do you draft on Magic Online',
     'How often do you play Constructed on Magic Online', 'Favorite formats to play', 'Favorite Draft Format', 'Favorite Magic Card',
     'Favorite piece of Magic art', 'Favorite Planeswalker card', 'If you could play Magic against anyone, who would it be and why']
  end
  
end