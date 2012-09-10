source 'http://rubygems.org'

# -----------
# CUSTOM GEMS
# -----------

gem "devise", "~> 2.1.2"                                            # user authentication
gem "devise-encryptable", "~> 0.1.1"
gem "simple_form", "~> 1.5.2"                                       # simplified form creation
gem "nokogiri", "~> 1.5.0"                                          # XML/HTML Parser
gem "activeadmin", "~> 0.5.0"                                       # Administrator Panel
gem "formtastic", "~> 2.1.1"                                        # for admin panel only
gem "kaminari", "~> 0.13.0"                                         # Pagination
gem "rails3-jquery-autocomplete", "~> 1.0.6"                        # Autocomplete text fields
gem "smart_tuple", "~> 0.1.2"                                       # Aid for building complex and conditional queries
gem "money", "~> 4.0.2"                                             # handles currency inputs and currency conversions if we need those in the future
#gem "encryptor", "~> 1.1.3"                                        # 2-way encryption using SSL
gem "heroku"                                                        # allows application to talk to heroku web hosting service
gem "rmagick", "~> 2.13.1"                                          # image manipulation (requires install of rmagick software)
gem "carrierwave", "~> 0.6.2"                                       # image_scan uploader
gem "fog", "~> 1.3.1"                                               # supports amazon s3
gem "activemerchant", "~> 1.26.0", :require => 'active_merchant'    # integration of PayPal
gem "active_paypal_adaptive_payment", "~> 0.3.15"                   # Adaptive Payments for ActiveMerchant for withdraws
gem "ckeditor", "~> 3.7.1"                                          # blog editor
gem "mini_magick", "~> 3.4"                                         # image manipulation for ckeditor
gem "girl_friday", "~> 0.10.0"                                      # background processing for unicorn... disabled due to issues
gem 'unicorn'                                                       # custom webserver with multi-threaded application capabilities

#gem "active_shipping", "~> 0.9.14"                                  # shipping rates for USPS
#gem "usps_standardizer", "~> 0.4.2"

gem "honeypot-captcha", "~> 0.0.2"                                  # alternative to capcha without the complexity  
gem "taps", "~> 0.3.24"                                             # ability to pull and push databases from development to production


# -------------
# STANDARD GEMS
# -------------

gem 'jquery-rails'                                                  # latest jquery library.  need to include "//= require jquery_ujs" and "//= require jquery" in application.js to be loaded in asset pipeline
gem "rails", "~> 3.2.8"
gem 'json'


group :production do
  gem "mysql2"                                                      # allows application to use a mysql database  
  gem "newrelic_rpm", "~> 3.3.2"                                    # performance monitoring
  gem "dalli", "~> 2.2"                                               # memcache for heroku
end

group :development do
  gem 'sqlite3'
  gem 'hooves', :require => 'hooves/default'          # unicorn works with "rails s"
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'yui-compressor'
end



# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'


# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

