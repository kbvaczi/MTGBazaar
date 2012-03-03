module AccountDepositsHelper
  
  def list_deposit_options
    deposit_options = Array.new
    deposit_options << ["#{number_to_currency(10)}", 1000]
    15.times do |i|
      deposit_options << ["#{number_to_currency((i+1)*20)}", (i+1)*2000]    
    end    
    return deposit_options.sort! {|x,y| y[0].to_i <=> x[0].to_i }.uniq
  end
 
end
