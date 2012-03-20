class CartsController < ApplicationController
  
  def add_mtg_card
    current_cart.add_mtg_listing(Mtg::Listing.find(params[:id])) # add this listing to cart
    redirect_to back_path, :notice => "Card added to cart!"
    return #stop method, don't display a view
  end
  
  def remove_mtg_card
    current_cart.remove_mtg_listing(Mtg::Listing.find(params[:id])) # remove this listing from cart
    redirect_to back_path, :notice => "Card removed!"
    return #stop method, don't display a view
  end
  
  def checkout
    if current_user.account.balance >= current_cart.total_price # does user have money to purchase?
      current_user.account.update_attribute(:balance, current_user.account.balance - current_cart.total_price)  # take money out of user's balance
      current_cart.seller_ids.each do |id|
        @transaction = Mtg::Transaction.create()
        @seller = User.find(id)
        current_user.mtg_purchases.push(@transaction) # create transaction for this buyer
        @seller.mtg_sales.push(@transaction) # add seller
        current_cart.mtg_listings_for_seller_id(id).each { |l| @transaction.listings.push(l) } # add the listings to transaction
        ApplicationMailer.send_seller_sale_notification(@transaction).deliver # send sale notification email to seller
      end
      current_cart.empty! # empty the shopping cart
      redirect_to back_path, :notice => "Your purchase has been submitted.  Expect seller confirmation soon."
    else
      create_back_path # set back path so that user is returned to cart after depositing
      flash[:error] = "Insufficient Balance... Please deposit funds." 
      redirect_to new_account_deposit_path # redirect to deposit page
    end
    return #stop method, don't display a view
  end
  
end