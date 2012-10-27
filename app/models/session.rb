class Session < ActiveRecord::Base
  
  before_destroy :clear_cart
  
  # clear associated cart before destroying session
  def clear_cart
    this_cart = self.cart
    if this_cart.present?
      Rails.logger.info "  - session ID:#{self.id} destroyed with cart ID:#{this_cart.id}"
      this_cart.empty_and_destroy
    end
  end
  
  # finds associated cart returns cart object.
  def cart
    Cart.find(ActiveRecord::SessionStore::Session.find_by_session_id(self.session_id).data["cart_id"]) rescue nil
  end
  
  def user
    User.find(ActiveRecord::SessionStore::Session.find_by_session_id(self.session_id).data["warden.user.user.key"][1]) rescue nil
  end
  
end