class TeamZ::MtgoVideo < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'team_z_mtgo_videos'    
  
  belongs_to :video_series, :class_name => "TeamZ::MtgoVideoSeries", :foreign_key => "video_series_id"

  # override default route to add username in route.
  def to_param
    "#{id}-#{self.title}".parameterize
  end

  # ----- Validations ----- #

  validates_presence_of :video_link

  # ----- Callbacks ----- #
  
  before_save :format_video_link
  
  def format_video_link
    #http://youtu.be/1E1e6D2zvGQ&whatever=whatever
    #http://www.youtube.com/watch?v=1E1e6D2zvGQ&feature=youtu.be
    #http://www.youtube.com/embed/1E1e6D2zvGQ"
    Rails.logger.info(self.video_link)
    Rails.logger.info(self.video_link)    
    case self.video_link
      when /\/watch\?/
        self.video_link = "https://www.youtube.com/embed/#{self.video_link.split('?v=')[1].split('&')[0]}"
      when /\/embed\//
        self.video_link = "https://#{self.video_link.gsub('https://','').gsub('http://','')}"
      when /youtu.be/
        self.video_link = "https://www.youtube.com/embed/#{self.video_link.split('tu.be/')[1].split('&')[0]}"
    end
          Rails.logger.info(self.video_link)
                Rails.logger.info(self.video_link)
  end

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
  
  def video_embed_object
    %{<iframe width="420" height="315" src="#{self.video_link}" frameborder="0" allowfullscreen></iframe>}
  end
  
end