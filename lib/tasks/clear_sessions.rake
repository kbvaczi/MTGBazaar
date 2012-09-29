# Description:  this task clears all expired sessions and empties shopping carts associated with these expired sessions
# Schedule:     run every 30 minutes or more frequently

task :clear_expired_sessions => :environment do
  Rails.logger.info "Running clear_expired_sessions task:"
  Session.all.each do |s|
    if s.updated_at < 30.minutes.ago.to_s(:db) or s.created_at < 1.days.ago.to_s(:db) # if session has expired (not touched in 30 minutes or more than a day old)
=begin
      Rails.logger.debug " found expired session ID:#{s.id}"
      cart_id = ActiveRecord::SessionStore::Session.find_by_session_id(s.session_id).data["cart_id"] # find the cart associated with this session
      if cart_id.present? # does this session have an active cart?
        cart = Cart.includes(:reservations => :listing).where(:id => cart_id).first # find the cart associated with this session        
        if cart.present?
          Rails.logger.debug "  -found cart ID:#{cart.id} with #{cart.item_count} listings"
          cart.empty # remove all listings out of this cart and make them available for other users to purchase
          Rails.logger.debug "  -cart ID:#{cart.id} was emptied and now has #{cart.item_count} listings"      
          cart.destroy # delete this cart
          Rails.logger.debug "  -cart ID:#{cart.id} destroyed"      
        end
      end
=end
      s.destroy # delete this session.
      Rails.logger.debug "  -session ID:#{s.id} destroyed"
    end
  end  
  Rails.logger.info "clear_expired_sessions task complete!"
end