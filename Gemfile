source 'http://rubygems.org'

# -----------
# CUSTOM GEMS
# -----------

gem "devise", "~> 2.0.0"                                            # user authentication
gem "simple_form", "~> 1.5.2"                                       # simplified form creation
gem "recaptcha", "~> 0.3.4", :require => "recaptcha/rails"          # Bot prevention
gem "nokogiri", "~> 1.5.0"                                          # XML/HTML Parser
gem "activeadmin", "~> 0.4.0"                                       # Administrator Panel
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
#gem "activemerchant", "~> 1.26.0"                                  # integration of PayPal
gem "ckeditor", "~> 3.7.1"                                          # blog editor
gem "mini_magick", "~> 3.4"                                         # image manipulation for ckeditor
gem "girl_friday", "~> 0.9.7"                                       # background processing for unicorn
gem 'unicorn'                                                       # custom webserver with multi-threaded application capabilities

# -------------
# STANDARD GEMS
# -------------

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'
gem 'jquery-rails'                                                  # latest jquery library.  need to include "//= require jquery_ujs" and "//= require jquery" in application.js to be loaded in asset pipeline
gem 'rails', '3.2.0'
gem 'json'
gem 'sass-rails',   '~> 3.2.3'                                      # take sass-rails out of assets group to prevent problems with heroku

group :production do
  gem "mysql2"                                                      # allows application to use a mysql database  
  gem "newrelic_rpm", "~> 3.3.2"                                    # performance monitoring
  #gem 'thin'                                                       # production webserver... using unicorn instead of thin
end

group :development, :test do
  gem 'sqlite3'
  #gem 'rails-dev-tweaks', '~> 0.6.1' #improves performance in development environment  
  
  gem 'hooves'                      # makes "rails s" work with unicorn
  require 'hooves/default'          # this is needed for hooves to work (i forgot why)
  
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end



# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'


# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

