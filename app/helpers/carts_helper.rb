module CartsHelper
  
  def update_quantity_in_cart_selection(reservation)
    total_available = reservation.quantity + reservation.listing.quantity_available
    if total_available < 50
      (1..total_available).to_a
    else
      range = 25
      range_lower_bound = reservation.quantity > range ? reservation.quantity - range : 2
      range_upper_bound = reservation.quantity + range > total_available ? total_available : reservation.quantity + range
      (1..1).to_a + (range_lower_bound...reservation.quantity).to_a + (reservation.quantity...range_upper_bound).to_a + (total_available..total_available).to_a
    end
  end

end
