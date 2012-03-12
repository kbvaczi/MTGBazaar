source 'http://rubygems.org'

# -----------
# CUSTOM GEMS
# -----------

gem "devise", "~> 2.0.0"                                            # user authentication
gem "simple_form", "~> 1.5.2"                                       # simplified form creation
gem "chosen_rails", "~> 0.1.0"                                      # customized select boxes using chosen (http://harvesthq.github.com/chosen/). requires jquery
gem 'jquery-rails'                                                  # latest jquery library.  need to include "//= require jquery_ujs" and "//= require jquery" in application.js to be loaded in asset pipeline
gem "recaptcha", "~> 0.3.4", :require => "recaptcha/rails"          # Bot prevention
gem "nokogiri", "~> 1.5.0"                                          # XML/HTML Parser
gem "activeadmin", "~> 0.4.0"                                       # Administrator Panel
gem "kaminari", "~> 0.13.0"                                         # Pagination
gem "rails3-jquery-autocomplete", "~> 1.0.6"                        # Autocomplete text fields
gem "smart_tuple", "~> 0.1.2"                                       # Aid for building complex and conditional queries
gem "money", "~> 4.0.2"                                             # handles currency inputs and currency conversions if we need those in the future
gem "encryptor", "~> 1.1.3"                                         # 2-way encryption using SSL
gem "heroku"                                                        # allows application to talk to heroku web hosting service

# -------------
# STANDARD GEMS
# -------------

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'
gem 'rails', '3.2.0'
gem 'json'
gem 'sass-rails',   '~> 3.2.3'                                      # take sass-rails out of assets group to prevent problems with heroku

group :production do
  gem "mysql2"                                                      # allows application to use a mysql database  
  gem "newrelic_rpm", "~> 3.3.2"                                    # performance monitoring
end

group :development, :test do
  gem 'sqlite3'
  gem 'rails-dev-tweaks', '~> 0.6.1' #improves performance in development environment  
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end



# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

