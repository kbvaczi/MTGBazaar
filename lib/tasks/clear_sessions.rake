# this task clears all expired sessions
task :clear_expired_sessions => :environment do
  #Session.all.each do |s|
  #  if s.updated_at < 0.minutes.ago.to_s(:db) or s.created_at < 2.days.ago.to_s(:db) # if session has expired
  #    Cart.initialize(ActiveRecord::SessionStore::Session.find_by_session_id(self.session_id).empty! # empty cart contents to free up merchandise before deleting session
  #    s.destroy # delete this session.
  #  end
  #end  
end