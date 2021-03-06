module Account::SellerPanelHelper
  
  def price_analysis_pricepoint
    query = %{  SELECT  AVG(CASE WHEN mtg_listings.condition = 1 THEN (mtg_listings.price - (#{Mtg::Cards::Statistics.price_reduction_from_condition(1)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item)) / ((mtg_card_statistics.price_high - mtg_card_statistics.price_low) * #{Mtg::Cards::Statistics.price_reduction_from_condition(1)} * mtg_listings.number_cards_per_item)
                                 WHEN mtg_listings.condition = 2 THEN (mtg_listings.price - (#{Mtg::Cards::Statistics.price_reduction_from_condition(2)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item)) / ((mtg_card_statistics.price_high - mtg_card_statistics.price_low) * #{Mtg::Cards::Statistics.price_reduction_from_condition(2)} * mtg_listings.number_cards_per_item)
                                 WHEN mtg_listings.condition = 3 THEN (mtg_listings.price - (#{Mtg::Cards::Statistics.price_reduction_from_condition(3)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item)) / ((mtg_card_statistics.price_high - mtg_card_statistics.price_low) * #{Mtg::Cards::Statistics.price_reduction_from_condition(3)} * mtg_listings.number_cards_per_item)
                                 ELSE                                 (mtg_listings.price - (#{Mtg::Cards::Statistics.price_reduction_from_condition(4)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item)) / ((mtg_card_statistics.price_high - mtg_card_statistics.price_low) * #{Mtg::Cards::Statistics.price_reduction_from_condition(4)} * mtg_listings.number_cards_per_item) END ) AS pricepoint                              
                  FROM  mtg_listings
                  JOIN  (mtg_card_statistics, users)
                    ON  (mtg_listings.card_id = mtg_card_statistics.card_id AND users.id = mtg_listings.seller_id)
                 WHERE  users.id = #{current_user.id}
                        AND mtg_card_statistics.price_low IS NOT NULL AND mtg_card_statistics.price_low > 0
                        AND mtg_listings.foil = 0 AND mtg_listings.language = 'EN' AND mtg_listings.misprint = 0 AND mtg_listings.signed = 0 AND mtg_listings.altart = 0 }
    @price_analysis_pricepoint ||= ActiveRecord::Base.connection.select(query).first['pricepoint'] * 10 rescue 0
  end

  def listings_price_analysis(listing_ids_array = nil)
    listing_ids_array_sql = listing_ids_array.to_s.gsub('[','(').gsub(']',')')        
    query = %{  SELECT mtg_listings.id,
                       mtg_card_statistics.price_min,      
                       mtg_card_statistics.price_low,
                       mtg_card_statistics.price_med,                       
                       mtg_card_statistics.price_high,                       
                       CASE WHEN mtg_listings.condition = 1 THEN (mtg_listings.price - (#{Mtg::Cards::Statistics.price_reduction_from_condition(1)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item)) / ((mtg_card_statistics.price_high - mtg_card_statistics.price_low) * #{Mtg::Cards::Statistics.price_reduction_from_condition(1)} * mtg_listings.number_cards_per_item * 10)
                            WHEN mtg_listings.condition = 2 THEN (mtg_listings.price - (#{Mtg::Cards::Statistics.price_reduction_from_condition(2)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item)) / ((mtg_card_statistics.price_high - mtg_card_statistics.price_low) * #{Mtg::Cards::Statistics.price_reduction_from_condition(2)} * mtg_listings.number_cards_per_item * 10)
                            WHEN mtg_listings.condition = 3 THEN (mtg_listings.price - (#{Mtg::Cards::Statistics.price_reduction_from_condition(3)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item)) / ((mtg_card_statistics.price_high - mtg_card_statistics.price_low) * #{Mtg::Cards::Statistics.price_reduction_from_condition(3)} * mtg_listings.number_cards_per_item * 10)
                            ELSE                                 (mtg_listings.price - (#{Mtg::Cards::Statistics.price_reduction_from_condition(4)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item)) / ((mtg_card_statistics.price_high - mtg_card_statistics.price_low) * #{Mtg::Cards::Statistics.price_reduction_from_condition(4)} * mtg_listings.number_cards_per_item * 10) END AS pricepoint                              
                 FROM  mtg_listings
                 JOIN  (mtg_card_statistics, users)
                   ON  (mtg_listings.card_id = mtg_card_statistics.card_id AND users.id = mtg_listings.seller_id)
                WHERE  users.id = #{current_user.id}
                       AND mtg_listings.foil = 0 AND mtg_listings.language = 'EN' AND mtg_listings.misprint = 0 AND mtg_listings.signed = 0 AND mtg_listings.altart = 0 
                    #{"AND mtg_listings.id IN #{listing_ids_array_sql}" if listing_ids_array.present?} ; }           
    @listings_price_analysis ||= ActiveRecord::Base.connection.select(query).group_by {|i| i['id']}
  end

  
  def card_ids_below_recommended_price_range
    margin_of_error_factor = 0.95 # only throws out of range warning if you're more thab this range of error below low price... prevents too many alarms on normal daily price fluctuations
    query = %{  SELECT  mtg_listings.id                        
                  FROM  mtg_listings
                  JOIN  (mtg_card_statistics, users)
                    ON  (mtg_listings.card_id = mtg_card_statistics.card_id AND users.id = mtg_listings.seller_id)
                 WHERE  users.id = #{current_user.id}
                        AND mtg_card_statistics.price_low IS NOT NULL AND mtg_card_statistics.price_low > 0                 
                        AND mtg_listings.foil = 0 AND mtg_listings.language = 'EN' AND mtg_listings.misprint = 0 AND mtg_listings.signed = 0 AND mtg_listings.altart = 0
                        AND mtg_listings.price < CASE WHEN mtg_listings.condition = 1 THEN #{Mtg::Cards::Statistics.price_reduction_from_condition(1)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item * #{margin_of_error_factor} - 1
                                                      WHEN mtg_listings.condition = 2 THEN #{Mtg::Cards::Statistics.price_reduction_from_condition(2)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item * #{margin_of_error_factor} - 1
                                                      WHEN mtg_listings.condition = 3 THEN #{Mtg::Cards::Statistics.price_reduction_from_condition(3)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item * #{margin_of_error_factor} - 1 
                                                                                      ELSE #{Mtg::Cards::Statistics.price_reduction_from_condition(4)} * mtg_card_statistics.price_low * mtg_listings.number_cards_per_item * #{margin_of_error_factor} - 1 END ; }
    @card_ids_below_recommended_price_range ||= ActiveRecord::Base.connection.select(query).collect{|a| a['id'].to_i}
  end
  
  def card_ids_above_recommended_price_range
    margin_of_error_factor = 1.05 # only throws out of range warning if you're more thab this range of error above high price... prevents too many alarms on normal daily price fluctuations    
    query = %{  SELECT  mtg_listings.id                        
                  FROM  mtg_listings
                  JOIN  (mtg_card_statistics, users)
                    ON  (mtg_listings.card_id = mtg_card_statistics.card_id AND users.id = mtg_listings.seller_id)
                 WHERE  users.id = #{current_user.id}
                        AND mtg_card_statistics.price_low IS NOT NULL AND mtg_card_statistics.price_low > 0                 
                        AND mtg_listings.foil = 0 AND mtg_listings.language = 'EN' AND mtg_listings.misprint = 0 AND mtg_listings.signed = 0 AND mtg_listings.altart = 0
                        AND mtg_listings.price > CASE WHEN mtg_listings.condition = 1 THEN #{Mtg::Cards::Statistics.price_reduction_from_condition(1)} * mtg_card_statistics.price_high * mtg_listings.number_cards_per_item * #{margin_of_error_factor} + 1 
                                                      WHEN mtg_listings.condition = 2 THEN #{Mtg::Cards::Statistics.price_reduction_from_condition(2)} * mtg_card_statistics.price_high * mtg_listings.number_cards_per_item * #{margin_of_error_factor} + 1
                                                      WHEN mtg_listings.condition = 3 THEN #{Mtg::Cards::Statistics.price_reduction_from_condition(3)} * mtg_card_statistics.price_high * mtg_listings.number_cards_per_item * #{margin_of_error_factor} + 1
                                                                                      ELSE #{Mtg::Cards::Statistics.price_reduction_from_condition(4)} * mtg_card_statistics.price_high * mtg_listings.number_cards_per_item * #{margin_of_error_factor} + 1 END ; }
    @card_ids_above_recommended_price_range ||= ActiveRecord::Base.connection.select(query).collect{|a| a['id'].to_i}
  end

end
