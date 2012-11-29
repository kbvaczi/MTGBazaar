class AddListingsMtgCardsToUserStatistics < ActiveRecord::Migration
  
  class UserStatistics < ActiveRecord::Base    # create faux model to avoid validation issues
  end
  
  def up
    add_column(   :user_statistics, :listings_mtg_cards_count, :integer, :default => 0 )    unless column_exists?(:user_statistics, :listings_mtg_cards_count)

    UserStatistics.reset_column_information   # setup faux model
    UserStatistics.all.each do |us|
      us.update_attribute(:listings_mtg_cards_count, Mtg::Cards::Listing.available.where(:seller_id => us.user_id).sum(:quantity_available))
    end
  end
  
  def down
    remove_column( :user_statistics, :listings_mtg_cards_count) if      column_exists?(:user_statistics, :listings_mtg_cards_count)
  end

end
