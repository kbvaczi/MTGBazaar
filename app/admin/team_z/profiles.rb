# encoding: UTF-8
ActiveAdmin.register TeamZ::Profile do
  menu :label => "Profiles", :parent => "Team Z"

  form :partial => "admin/team_z/profiles/form"
  
end
