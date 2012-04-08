# Description:  this task clears all expired sessions and empties shopping carts associated with these expired sessions
# Schedule:     run every 30 minutes

task :clear_expired_sessions => :environment do
  puts "Running clear_expired_sessions task:"
  Session.all.each do |s|
    if s.updated_at < 30.minutes.ago.to_s(:db) or s.created_at < 1.days.ago.to_s(:db) # if session has expired
      puts " found expired session ID:#{s.id}"
      cart = Cart.find(ActiveRecord::SessionStore::Session.find_by_session_id(s.session_id).data["cart_id"]) # find the cart associated with this session
      puts "  -found cart ID:#{cart.id} with #{cart.item_count} listings"
      cart.empty! # remove all listings out of this cart and make them available for other users to purchase
      puts "  -cart ID:#{cart.id} was emptied and now has #{cart.item_count} listings"      
      cart.destroy # delete this cart
      puts "  -cart ID:#{cart.id} destroyed"      
      s.destroy # delete this session.
      puts "  -session ID:#{s.id} destroyed"
    end
  end  
  puts "clear_expired_sessions task complete!"
end