class TeamZ::ArticlesController < TeamZ::BaseController

  before_filter :verify_team_z_member,     :except  => [:show]
  before_filter :verify_article_ownership, :except  => [:show, :index, :new, :create, :publish, :edit_to_publish]
  before_filter :verify_content_manager,   :only    => [:publish, :edit_to_publish]
  
  def index
    set_back_path
    if params[:role] == 'content_manager' && current_user.team_z_profile.can_manage_content
      respond_to do |format|
        format.html { render :template => 'team_z/articles/index_as_manager' }
        format.js   { default_js_render :template => 'team_z/articles/index_as_manager' }
      end
    else
      respond_to do |format|
        format.html { }
        format.js   { default_js_render :template => 'team_z/articles/index' }
      end
    end
  end
  
  def show
    set_back_path
    if current_article.present?
      respond_to do |format|
        format.html { }
        format.js   { default_js_render :template => 'team_z/articles/show' }
      end    
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def new
    @article ||= TeamZ::Article.new(params[:team_z_article])
    respond_to do |format|
      format.html { render :layout => 'full' }
    end
  end
  
  def create
    @article ||= TeamZ::Article.new(params[:team_z_article].merge(:active => false, :team_z_profile_id => current_user.team_z_profile_id, :active_at => nil))
    if @article.action == 'create'
      @article.status = 'complete'
    else
      @article.status = 'working'
    end
    if @article.save
      redirect_to back_path, :notice => 'Your article was created'
    else
      Rails.logger.debug @article.attributes
      Rails.logger.debug @article.errors.full_messages
      Rails.logger.debug @article.errors.full_messages            
      flash[:error] = 'There was a problem with your request...'
      render 'new', :layout => 'full'
    end
  end
  
  def edit
    current_article
    respond_to do |format|
      format.html { render :layout => 'full' }
    end
  end
  
  def update
    current_article.assign_attributes(params[:team_z_article].merge(:active => false, :team_z_profile_id => (current_article.team_z_profile_id || current_user.team_z_profile_id), :active_at => nil))
    if @article.action == 'create'
      @article.status = 'complete'
    else
      @article.status = 'working'
    end
    if @article.save
      redirect_to back_path, :notice => 'Your article was successfully updated'
    else
      Rails.logger.debug @article.attributes
      Rails.logger.debug @article.errors.full_messages
      Rails.logger.debug @article.errors.full_messages            
      flash[:error] = 'There was a problem with your request...'
      render 'new', :layout => 'full'
    end    
  end
  
  def edit_to_publish
    if current_article.present?
      respond_to do |format|
        format.js   { }
      end    
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def publish
    current_article.assign_attributes(params[:team_z_article].merge(:team_z_profile_id => current_article.team_z_profile_id, :active => true, :status => 'approved'))
    Rails.cache.clear(TeamZ::Article.cache_key) if current_article.active_at < Time.zone.now
    if current_article.save
      redirect_to back_path, :notice => 'The article was published'
    else
      flash[:error] = 'There was a problem with your request...'
      redirect_to back_path
    end
  end
  
  def unpublish
    current_article.assign_attributes(:active => false, :active_at => nil, :status => 'complete')    
    if current_article.save
      redirect_to back_path, :notice => 'The article was un-published'
    else
      flash[:error] = 'There was a problem with your request...'
      redirect_to back_path
    end
  end
  
  def destroy
    if current_article.status == 'working' or current_user.team_z_profile.can_manage_content
      current_article.destroy
      redirect_to back_path, :notice => 'Your article was deleted...'
    else
      flash[:error] = 'You cannot delete completed articles...'
      redirect_to back_path
    end
  end
  
  private 
   
  def verify_article_ownership
    verify_ownership(current_article.id)
  end

  def current_article
    if user_signed_in? and current_user.team_z_profile.present? 
      @article ||= TeamZ::Article.includes(:profile).find(params[:id])
    else
      @article ||= TeamZ::Article.includes(:profile).viewable.where(:id => params[:id]).first
    end
  end
end