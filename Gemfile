source 'http://rubygems.org'

ruby '1.9.3'

# -----------
# CUSTOM GEMS
# -----------

gem "devise", "~> 2.1.2"                                            # user authentication
gem "devise-encryptable", "~> 0.1.1"
gem "simple_form", "~> 2.0.3"                                       # simplified form creation
gem "nokogiri", "~> 1.5.0"                                          # XML/HTML Parser
gem "activeadmin", "~> 0.5.0"                                       # Administrator Panel
gem "formtastic", "~> 2.1.1"                                        # for admin panel only
gem "kaminari", "~> 0.14"                                           # Pagination
gem "rails3-jquery-autocomplete", "~> 1.0.6"                        # Autocomplete text fields
gem "smart_tuple", "~> 0.1.2"                                       # Aid for building complex and conditional queries
gem "money", "~> 4.0.2"                                             # handles currency inputs and currency conversions if we need those in the future
gem "encryptor", "~> 1.1.3"                                         # 2-way encryption using SSL
gem "attr_encrypted", "~> 1.2.1"                                    # have rails automatically encrypt certain fields

#gem "heroku"                                                        # allows application to talk to heroku web hosting service
                                                                     # this gem is now depreciated to be replaced by the heroku toolbelt  
                                                                     
#gem "rmagick", "~> 2.13.1"                                         # image manipulation (requires install of rmagick software) # we replaced this with minimagic
gem "carrierwave", "~> 0.6.2"                                       # image_scan uploader
gem "fog", "~> 1.3.1"                                               # supports amazon s3

gem "activemerchant", "~> 1.26.0", :require => 'active_merchant'    # integration of PayPal
gem "active_paypal_adaptive_payment", "~> 0.3.15"                   # Adaptive Payments for ActiveMerchant for withdraws

gem "ckeditor", "~> 3.7.1"                                          # blog editor
gem "mini_magick", "~> 3.4"                                         # image manipulation for ckeditor

#gem "girl_friday", "~> 0.10.0"                                     # background processing for unicorn...
gem "sidekiq", "~> 2.6.1"                                           # redis backed background processing
gem "devise-async", "~> 0.5.0"                                      # devise emails sent in background
gem 'slim'                                                          # this is for sidekiq monitoring server  
gem 'sinatra', :require => nil                                      # this is for sidekiq monitoring server

gem 'unicorn'                                                       # custom webserver with multi-threaded application capabilities

#gem "stamps", "~> 0.3.0"                                           # API interface for stamps.com for printing shipping labels
gem 'stamps', :git => 'https://github.com/darnovo/stamps.git'       # forked repo with updated gem dependencies

gem "honeypot-captcha", "~> 0.0.2"                                  # alternative to capcha without the complexity  

gem "valium", "~> 0.5.0"                                            # improved activerecord queries?
gem "bulk_update", "~> 1.0.0"                                       # improved bulk update/create for activerecord

#gem "hirefireapp", "~> 0.0.8"                                       # auto-scaling dynos
gem "geocoder", "~> 1.1.5"

gem "httpclient", "~> 2.3.0.1"                                      # for paypal verify account code
gem "xml-simple", "~> 1.1.2"                                        # for paypal verify account code

gem "sitemap_generator", "~> 3.4"                                   # create XML sitemaps for search engines to use

# -------------
# STANDARD GEMS
# -------------


gem "rails", "~> 3.2.9"
gem "jquery-rails", "~> 2.1.4"                                      # some compatibility issues with using newest version so we're using this version for now
#gem 'jquery-rails'                                                 # latest jquery library.  need to include "//= require jquery_ujs" and "//= require jquery" in application.js to be loaded in asset pipeline
gem 'json'


group :production, :staging do
  gem "mysql2"                                                      # allows application to use a mysql database  
  gem "newrelic_rpm"                                                # performance monitoring
  gem "dalli"                                                       # enable memcache for heroku
  gem 'memcachier'                                                  # use memcachier through dalli on heroku
  gem 'rack-www'                                                    # allows use of middleware to add www. to domain calls (i.e. mtgbazaar.com)... using only in production
end

group :staging do

end

group :development do
  gem "mysql2"
  gem 'hooves', :require => 'hooves/default'          # unicorn works with "rails s"
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'yui-compressor'
  # gem 'asset_sync'                                                  # Load assets to S3 during compilation on Heroku, serve assets from S3
end



# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'


# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

