#Description: set sellers inactive who have not logged in for a period of time
#Schedule: run weekly or more frequently
 
task :set_sellers_inactive => :environment do
  Rails.logger.info "Running set_sellers_inactive task:"
  User.where("active = ? AND current_sign_in_at < ?", true, 1.month.ago.to_s(:db)).update_all(:active => false)
  Mtg::Transaction.where("seller_id IS ? AND buyer_id IS ? AND created_at < ?", nil, nil, 1.hours.ago.to_s(:db)).destroy_all
  Rails.logger.info "set_sellers_inactive task complete!"
end