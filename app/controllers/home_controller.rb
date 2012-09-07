class HomeController < ApplicationController

  include ActiveMerchant::Shipping
  
  def index

    # TESTING ACTIVE SHIPPING
=begin
    
    # Package up a poster and a Wii for your nephew.
    packages = [
      Package.new(  100,                        # 100 grams
                    [93,10],                    # 93 cm long, 10 cm diameter
                    :cylinder => true),         # cylinders have different volume calculations

      Package.new(  (7.5 * 16),                 # 7.5 lbs, times 16 oz/lb.
                    [15, 10, 4.5],              # 15x10x4.5 inches
                    :units => :imperial)        # not grams, not centimetres
    ]

    # You live in Beverly Hills, he lives in Ottawa
    origin = Location.new(      :country => 'US',
                                :state => 'CA',
                                :city => 'Beverly Hills',
                                :zip => '90210')

    destination = Location.new(                             :country => 'US',
                                                            :state => 'CA',
                                                            :city => 'Beverly Hills',
                                                            :zip => '90210')

    # Check out USPS for comparison...
    @usps = USPS.new(:login => '403MTGBA0147', :test => true)
#    response = usps.find_rates(origin, destination, packages)

#    @usps_rates = response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}
=end
    if user_signed_in?
      @news_feeds = NewsFeed.where("active LIKE ?", true)
                            .where("start_at < \'#{Time.now}\' OR start_at IS null")
                            .where("end_at > \'#{Time.now}\' OR end_at IS null")
                            .order("created_at DESC")
                            .limit(1)
                            #.page(params[:page])
                            #.per(5)
    else
    
      @news_feeds = NewsFeed.where(:id => 1)
  
    end
  end
  
end
