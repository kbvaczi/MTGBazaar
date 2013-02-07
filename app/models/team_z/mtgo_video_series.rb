class TeamZ::MtgoVideoSeries < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'team_z_mtgo_video_series'    
  
  belongs_to :profile, :class_name => "TeamZ::Profile",   :foreign_key => "team_z_profile_id"
  has_many   :videos,  :class_name => "TeamZ::MtgoVideo", :foreign_key => 'video_series_id', :dependent => :destroy

  # override default route to add username in route.
  def to_param
    "#{id}-#{self.title}".parameterize
  end
  
  # allow form for accounts nested inside user signup/edit forms
  accepts_nested_attributes_for :videos, :reject_if => lambda { |a| a[:video_link].blank? }, :allow_destroy => true

  # ----- Validations ----- #

  validates_presence_of :profile, :title, :description
  validates_associated  :videos

  # ----- Callbacks ----- #    

  before_create :set_active_at
  
  def set_active_at
    self.active_at = Time.now unless self.active_at
  end

  # ----- Scopes ------ #
  
  def self.active
    where('team_z_mtgo_video_series.active' => true)
  end
  
  def self.inactive
    where('team_z_mtgo_video_series.active' => false)
  end  
  
  def self.viewable
    joins(:profile).where("team_z_profiles.active" => true, 'team_z_mtgo_video_series.active' => true).where("team_z_mtgo_video_series.active_at < ? OR team_z_mtgo_video_series.active_at IS ?", Time.now, nil)
  end
  
  def self.featured
    viewable.where('team_z_mtgo_video_series.featured' => true)
  end

  # ----- Instance Methods ----- #
  
  def posted_at
    if self.active_at == nil || self.created_at >= self.active_at 
      self.created_at
    else
      self.active_at
    end
  end
  
  # ----- Class Methods ----- #
  
  
end