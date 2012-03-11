class Session < ActiveRecord::Base
  
  # deletes sessions not touched in the last hour or that were created more than two days ago
  def self.sweep(time = 1.hour)
    if time.is_a?(String)
      time = time.split.inject { |count, unit| count.to_i.send(unit) }
    end
    
#    if updated_at < time.ago.to_s(:db) or created_at < 2.days.ago.to_s(:db)
#    delete_all "updated_at < '#{time.ago.to_s(:db)}' OR
#                created_at < '#{2.days.ago.to_s(:db)}'"
  end
  
end