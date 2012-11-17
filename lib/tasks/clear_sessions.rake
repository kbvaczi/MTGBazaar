# Description:  this task clears all expired sessions and empties shopping carts associated with these expired sessions
# Schedule:     run every 30 minutes or more frequently

task :clear_expired_sessions => :environment do
  Rails.logger.info "Running clear_expired_sessions task:"
  Session.where("updated_at < ? OR created_at < ?", 1.hours.ago.to_s(:db), 1.days.ago.to_s(:db)).destroy_all
  Rails.logger.info "clear_expired_sessions task complete!"
end

# Description:  this task clears all transactions and reservations prepped for checkout, but were never checked out...
# Schedule:     run every day more frequently

task :clear_empty_transactions => :environment do
  Rails.logger.info "Running clear_empty_transactions task:"
  Mtg::Transaction.where("seller_id IS ? AND buyer_id IS ? AND created_at < ?", nil, nil, 1.hours.ago.to_s(:db)).destroy_all
  Rails.logger.info "clear_empty_transactions task complete!"
end