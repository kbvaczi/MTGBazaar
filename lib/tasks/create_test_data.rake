# encoding: UTF-8


namespace :create_test_data do
    task :listings => :environment do 
      include Mtg::CardsHelper
      puts "Starting to create listings"
      card_count = Mtg::Card.all.count        
      user_count = User.all.count
      (ENV['count'].to_i || 1).times do      
        Mtg::Cards::Listing.create({:seller_id => rand(user_count - 1) + 1, #random number from 1 to user_count-1 
                             :card_id => rand(card_count -1) + 1,
                             :language => Mtg::CardsHelper.language_list[rand(Mtg::CardsHelper.language_list.length)][1],
                             :quantity => rand(100) + 1,
                             :price => (rand(1000) + 1).to_f / 100,
                             :condition => Mtg::CardsHelper.condition_list[rand(Mtg::CardsHelper.condition_list.length)][1]}, :without_protection => true)
      end
      puts "Finished creating #{      (ENV['count'] || 1)} listings"      
    end
end # namespace mtg