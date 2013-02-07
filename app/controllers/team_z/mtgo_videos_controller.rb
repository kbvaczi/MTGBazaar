class TeamZ::MtgoVideosController < TeamZ::BaseController

  def show
    @video        = TeamZ::MtgoVideo.includes(:profile).find(params[:id])
    respond_to do |format|
      format.html { }
      format.js   { default_js_render :template => 'team_z/mtgo_videos/show' }
    end    
  end
  
end