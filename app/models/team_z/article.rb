class TeamZ::Article < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'team_z_articles'    
  
  belongs_to :profile, :class_name => "TeamZ::Profile", :foreign_key => "team_z_profile_id"

  # override default route to add username in route.
  def to_param
    "#{id}-#{self.title}".parameterize
  end

  attr_accessor :action
  
  # ----- Validations ----- #

  validates_presence_of :team_z_profile_id, :title, :description, :body, :status

  # ----- Callbacks ----- #    

  before_create :set_active_at
  
  def set_active_at
    self.active_at = Time.zone.now if self.active and self.active_at.nil?
  end

  # ----- Scopes ------ #
  
  def self.viewable
    joins(:profile).where("team_z_profiles.active" => true, "team_z_articles.status" => 'approved', 'team_z_articles.active' => true).where("team_z_articles.active_at < ? OR team_z_articles.active_at IS ?", Time.now, nil)
  end
  
  def self.working
    joins(:profile).where('team_z_articles.status' => 'working')
  end
  
  def self.complete
    joins(:profile).where('team_z_articles.status' => 'complete')    
  end
  
  def self.approved
    joins(:profile).where('team_z_articles.status' => 'approved')        
  end
  
  def self.featured
    viewable.where('team_z_articles.featured' => true)
  end

  # ----- Instance Methods ----- #
  
  def posted_at
    if self.active_at == nil || self.created_at >= self.active_at 
      self.created_at
    else
      self.active_at
    end
  end

  # ----- Model Methods Methods ----- #
  
  def self.cache_key
    'content_newest_articles'
  end
  
end