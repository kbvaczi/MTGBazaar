class Session < ActiveRecord::Base
  
  before_destroy :clear_cart, :if => :cart
  
  # clear associated cart before destroying session
  def clear_cart
    Rails.logger.info "  - session ID:#{self.id} destroyed with cart ID:#{cart.id}"
    cart.empty!
    cart.destroy
  end
  
  # finds associated cart returns cart object.
  def cart
    @cart ||= Cart.find(ActiveRecord::SessionStore::Session.find_by_session_id(self.session_id).data["cart_id"]) rescue nil
  end
  
  def user
    User.find(ActiveRecord::SessionStore::Session.find_by_session_id(self.session_id).data["warden.user.user.key"][1])
  end
  
end