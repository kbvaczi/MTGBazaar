class TeamZ::Article < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'team_z_articles'    
  
  belongs_to :profile, :class_name => "TeamZ::Profile", :foreign_key => "team_z_profile_id"

  # override default route to add username in route.
  def to_param
    "#{id}-#{self.title}".parameterize
  end

  # ----- Validations ----- #

  validates_presence_of :team_z_profile_id, :title, :summary, :body, :approved, :active

  # ----- Callbacks ----- #    

  before_create :set_active_at
  
  def set_active_at
    self.active_at = Time.now unless self.active_at
  end

  # ----- Scopes ------ #
  
  def self.viewable
    where("team_z_profiles.active" => true, "team_z_articles.approved" => true, "team_z_articles.active" => true).where("team_z_articles.active_at < ? OR team_z_articles.active_at IS ?", Time.now, nil)
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