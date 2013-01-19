class TeamZ::BaseController < ApplicationController
    
  protected
  
  def verify_team_z_member
    unless user_signed_in? and current_user.team_z_profile_id.present?
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to back_path      
    end
  end  
  
  def verify_ownership(id)
    unless current_user.present? and (current_user.team_z_profile_id == id or current_user.team_z_profile.can_manage_content)
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to back_path
    end
  end
  
  def verify_content_manager
    unless current_user.present? and current_user.team_z_profile.can_manage_content
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to back_path
    end
  end
  
end