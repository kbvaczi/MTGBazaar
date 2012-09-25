# encoding: UTF-8


namespace :create_test_data do
    task :listings => :environment do 
      include Mtg::CardsHelper
      puts "Starting to create listings"
      card_count = Mtg::Card.all.count        
      user_count = User.all.count
      (ENV['count'].to_i || 1).times do      
        Mtg::Listing.create({:seller_id => rand(1..user_count), 
                             :card_id => rand(1..card_count),
                             :language => Mtg::CardsHelper.language_list[rand(Mtg::CardsHelper.language_list.length) -1 ][1],
                             :quantity => rand(1..100),
                             :price => rand(1..1000).to_f / 100,
                             :condition => Mtg::CardsHelper.condition_list[rand(Mtg::CardsHelper.condition_list.length) -1][1]}, :without_protection => true)
      end
      puts "Finished creating #{      (ENV['count'] || 1)} listings"      
    end
end # namespace mtg