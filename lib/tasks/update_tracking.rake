#Description: Updates tracking for every active transaction
#             If a transaction has not been marked as shipped, but tracking is active, this task sets transaction as shipped and notifies buyer

#Schedule:    Run Every Morning at 5:00AM
 
task :update_tracking_for_active_labels => :environment do
  puts "Running update_tracking_for_active_labels task:"
  
  Mtg::Transactions::ShippingLabel.where(:status => "active").each do |label|
    begin 
      label.update_tracking   
    rescue Exception => message
      puts ("STAMPS TRACKING ERROR for Label ID:#{label.id} MESSAGE: #{message}")
    end
  end
  
  puts "update_tracking_for_active_labels task complete!"
end