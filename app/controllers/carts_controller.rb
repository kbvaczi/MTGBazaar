class CartsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def add_mtg_card
    if current_cart.add_mtg_listing(Mtg::Listing.find(params[:id])) # add this listing to cart
      redirect_to back_path, :notice => "Card added to cart!"
    else
      flash[:error] = "there was a problem processing your request"
      redirect_to back_path
    end
    return #stop method, don't display a view
  end
  
  def remove_mtg_card
    if current_cart.remove_mtg_listing(Mtg::Listing.find(params[:id])) # remove this listing from cart
      redirect_to back_path, :notice => "Card removed!"
    else
      flash[:error] = "there was a problem processing your request"
      redirect_to back_path
    end
    return #stop method, don't display a view
  end
  
  def checkout
    if current_user.account.balance >= current_cart.total_price # does user have money to purchase?
      current_cart.seller_ids.each do |id|
        @transaction = Mtg::Transaction.create(:buyer_id => current_user.id, :seller_id => id, :status => "pending", :buyer_confirmed_at => Time.now)
        current_cart.mtg_listings_for_seller_id(id).each { |l| l.mark_as_sold!(@transaction.id) } # add the listings to transaction and mark them as sold
        ApplicationMailer.send_seller_sale_notification(@transaction).deliver # send sale notification email to seller
      end
      current_user.account.balance_debit!(current_cart.total_price)  # take money out of user's balance
      current_cart.empty! # empty the shopping cart
      redirect_to back_path, :notice => "Your purchase has been submitted.  Expect seller confirmation soon."
    else
      set_back_path # set back path so that user is returned to cart after depositing
      flash[:error] = "Insufficient Balance... Please deposit funds." 
      redirect_to new_account_deposit_path # redirect to deposit page
    end
    return #stop method, don't display a view
  end
  
end